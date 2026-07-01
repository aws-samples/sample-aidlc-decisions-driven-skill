# AWS CDK — Infrastructure Patterns

<!-- last_verified: 2026-06-30 -->

> **Usage**: Load when D5 IaC = AWS CDK. Read ONLY the sections matching the D5 deploy target + detected dependencies from design/operations.md.
>
> **Language**: Templates shown in TypeScript (CDK's canonical language). For Python CDK projects, the agent translates construct patterns — same structure, `snake_case` naming, `aws_cdk` imports instead of `aws-cdk-lib`. For Java/Go CDK, same constructs with language-idiomatic syntax.
>
> **Version resolution**: Uses `aws-cdk-lib` (v2 unified package). At generation time, verify current CDK version from npm registry. Construct APIs are stable within v2 — patterns here remain valid across minor versions.

---

## Project Structure

```
infra/
├── bin/
│   └── app.ts               # CDK app entry point
├── lib/
│   ├── app-stack.ts          # Main stack (composes constructs)
│   ├── database.ts           # RDS construct
│   ├── service.ts            # ECS/Lambda construct
│   ├── networking.ts         # VPC construct
│   └── monitoring.ts         # Alarms construct
├── config/
│   ├── dev.ts                # Dev environment config
│   └── production.ts         # Prod environment config
├── cdk.json
├── package.json
└── tsconfig.json
```

### CDK App Entry Point

```typescript
// bin/app.ts
import * as cdk from 'aws-cdk-lib';
import { AppStack } from '../lib/app-stack';
import { devConfig, prodConfig } from '../config';

const app = new cdk.App();
const env = app.node.tryGetContext('env') || 'dev';
const config = env === 'production' ? prodConfig : devConfig;

new AppStack(app, `{Service}-${env}`, {
  env: { account: config.account, region: config.region },
  config,
});
```

### Environment Config

```typescript
// config/dev.ts
export const devConfig = {
  account: '123456789012',
  region: 'us-east-1',
  environment: 'dev',
  service: '{SERVICE}',
  appPort: 3000,
  scaling: { min: 1, max: 5 },
  database: { instanceClass: 'db.t3.micro', storage: 20 },
  monitoring: { errorThreshold: 50, latencyThresholdMs: 2000 },
};

// config/production.ts
export const prodConfig = {
  account: '123456789012',
  region: 'us-east-1',
  environment: 'production',
  service: '{SERVICE}',
  appPort: 3000,
  scaling: { min: 2, max: 20 },
  database: { instanceClass: 'db.t3.medium', storage: 50 },
  monitoring: { errorThreshold: 10, latencyThresholdMs: 1000 },
};
```

---

## Deploy Target: ECS Fargate

### Main Stack

```typescript
// lib/app-stack.ts
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { NetworkingConstruct } from './networking';
import { DatabaseConstruct } from './database';
import { ServiceConstruct } from './service';
import { MonitoringConstruct } from './monitoring';

interface AppConfig {
  environment: string;
  service: string;
  appPort: number;
  scaling: { min: number; max: number };
  database: { instanceClass: string; storage: number };
  monitoring: { errorThreshold: number; latencyThresholdMs: number };
}

export class AppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps & { config: AppConfig }) {
    super(scope, id, props);
    const { config } = props;

    const networking = new NetworkingConstruct(this, 'Networking', { environment: config.environment });

    const database = new DatabaseConstruct(this, 'Database', {
      vpc: networking.vpc,
      environment: config.environment,
      instanceClass: config.database.instanceClass,
      allocatedStorage: config.database.storage,
    });

    const service = new ServiceConstruct(this, 'Service', {
      vpc: networking.vpc,
      databaseSecret: database.secret,
      environment: config.environment,
      serviceName: config.service,
      port: config.appPort,
      scaling: config.scaling,
    });

    new MonitoringConstruct(this, 'Monitoring', {
      service: service.fargateService,
      targetGroup: service.targetGroup,
      environment: config.environment,
      errorThreshold: config.monitoring.errorThreshold,
      latencyThresholdMs: config.monitoring.latencyThresholdMs,
    });

    new cdk.CfnOutput(this, 'ServiceUrl', { value: `https://${service.loadBalancer.loadBalancerDnsName}` });
    new cdk.CfnOutput(this, 'DatabaseEndpoint', { value: database.instance.instanceEndpoint.hostname });
  }
}
```

### Networking Construct

```typescript
// lib/networking.ts
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export class NetworkingConstruct extends Construct {
  public readonly vpc: ec2.Vpc;

  constructor(scope: Construct, id: string, props: { environment: string }) {
    super(scope, id);

    this.vpc = new ec2.Vpc(this, 'Vpc', {
      maxAzs: 2,
      natGateways: props.environment === 'production' ? 2 : 1,
      subnetConfiguration: [
        { name: 'Public', subnetType: ec2.SubnetType.PUBLIC, cidrMask: 24 },
        { name: 'Private', subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS, cidrMask: 24 },
        { name: 'Isolated', subnetType: ec2.SubnetType.PRIVATE_ISOLATED, cidrMask: 24 },
      ],
    });
  }
}
```

### Service Construct (ECS Fargate + ALB)

```typescript
// lib/service.ts
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecs_patterns from 'aws-cdk-lib/aws-ecs-patterns';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import { Construct } from 'constructs';

interface ServiceProps {
  vpc: ec2.Vpc;
  databaseSecret: secretsmanager.ISecret;
  environment: string;
  serviceName: string;
  port: number;
  scaling: { min: number; max: number };
}

export class ServiceConstruct extends Construct {
  public readonly fargateService: ecs.FargateService;
  public readonly targetGroup: elbv2.ApplicationTargetGroup;
  public readonly loadBalancer: elbv2.ApplicationLoadBalancer;

  constructor(scope: Construct, id: string, props: ServiceProps) {
    super(scope, id);

    const cluster = new ecs.Cluster(this, 'Cluster', {
      vpc: props.vpc,
      containerInsights: props.environment === 'production',
    });

    const service = new ecs_patterns.ApplicationLoadBalancedFargateService(this, 'Service', {
      cluster,
      serviceName: `${props.serviceName}-${props.environment}`,
      cpu: props.environment === 'production' ? 512 : 256,
      memoryLimitMiB: props.environment === 'production' ? 1024 : 512,
      desiredCount: props.scaling.min,
      taskImageOptions: {
        image: ecs.ContainerImage.fromAsset('../', { file: 'Dockerfile' }),
        containerPort: props.port,
        environment: {
          NODE_ENV: props.environment,
          PORT: props.port.toString(),
          LOG_LEVEL: props.environment === 'production' ? 'info' : 'debug',
        },
        secrets: {
          DATABASE_URL: ecs.Secret.fromSecretsManager(props.databaseSecret),
        },
      },
      healthCheck: {
        command: ['CMD-SHELL', `curl -f http://localhost:${props.port}/health || exit 1`],
        interval: cdk.Duration.seconds(30),
        timeout: cdk.Duration.seconds(5),
        retries: 3,
        startPeriod: cdk.Duration.seconds(10),
      },
      circuitBreaker: { rollback: true },
    });

    // Auto-scaling
    const scaling = service.service.autoScaleTaskCount({
      minCapacity: props.scaling.min,
      maxCapacity: props.scaling.max,
    });
    scaling.scaleOnCpuUtilization('CpuScaling', { targetUtilizationPercent: 70 });
    scaling.scaleOnMemoryUtilization('MemoryScaling', { targetUtilizationPercent: 80 });

    // Health check on target group
    service.targetGroup.configureHealthCheck({
      path: '/health/ready',
      healthyThresholdCount: 2,
      unhealthyThresholdCount: 3,
      timeout: cdk.Duration.seconds(5),
      interval: cdk.Duration.seconds(30),
    });

    this.fargateService = service.service;
    this.targetGroup = service.targetGroup;
    this.loadBalancer = service.loadBalancer;
  }
}
```

### Database Construct

```typescript
// lib/database.ts
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

interface DatabaseProps {
  vpc: ec2.Vpc;
  environment: string;
  instanceClass: string;
  allocatedStorage: number;
}

export class DatabaseConstruct extends Construct {
  public readonly instance: rds.DatabaseInstance;
  public readonly secret: secretsmanager.ISecret;

  constructor(scope: Construct, id: string, props: DatabaseProps) {
    super(scope, id);

    this.instance = new rds.DatabaseInstance(this, 'Instance', {
      engine: rds.DatabaseInstanceEngine.postgres({ version: rds.PostgresEngineVersion.VER_16 }),
      instanceType: new ec2.InstanceType(props.instanceClass),
      vpc: props.vpc,
      vpcSubnets: { subnetType: ec2.SubnetType.PRIVATE_ISOLATED },
      allocatedStorage: props.allocatedStorage,
      maxAllocatedStorage: props.allocatedStorage * 5,
      storageEncrypted: true,
      multiAz: props.environment === 'production',
      backupRetention: cdk.Duration.days(props.environment === 'production' ? 7 : 1),
      deletionProtection: props.environment === 'production',
      removalPolicy: props.environment === 'production'
        ? cdk.RemovalPolicy.RETAIN
        : cdk.RemovalPolicy.DESTROY,
    });

    this.secret = this.instance.secret!;
  }
}
```

### Monitoring Construct (from design/operations.md)

```typescript
// lib/monitoring.ts
import * as cdk from 'aws-cdk-lib';
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import * as cloudwatch_actions from 'aws-cdk-lib/aws-cloudwatch-actions';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as elbv2 from 'aws-cdk-lib/aws-elasticloadbalancingv2';
import { Construct } from 'constructs';

interface MonitoringProps {
  service: ecs.FargateService;
  targetGroup: elbv2.ApplicationTargetGroup;
  environment: string;
  errorThreshold: number;
  latencyThresholdMs: number;
}

export class MonitoringConstruct extends Construct {
  constructor(scope: Construct, id: string, props: MonitoringProps) {
    super(scope, id);

    const alertTopic = new sns.Topic(this, 'AlertTopic', {
      topicName: `${cdk.Stack.of(this).stackName}-alerts`,
    });

    // 5xx error rate alarm
    new cloudwatch.Alarm(this, 'ErrorRate', {
      metric: props.targetGroup.metrics.httpCodeTarget(
        elbv2.HttpCodeTarget.TARGET_5XX_COUNT,
        { period: cdk.Duration.minutes(5), statistic: 'Sum' }
      ),
      threshold: props.errorThreshold,
      evaluationPeriods: 2,
      alarmDescription: 'High 5xx error rate',
    }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic));

    // High latency alarm
    new cloudwatch.Alarm(this, 'HighLatency', {
      metric: props.targetGroup.metrics.targetResponseTime({
        period: cdk.Duration.minutes(5),
        statistic: 'p99',
      }),
      threshold: props.latencyThresholdMs / 1000,
      evaluationPeriods: 3,
      alarmDescription: 'p99 latency above threshold',
    }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic));

    // CPU utilization alarm
    new cloudwatch.Alarm(this, 'HighCpu', {
      metric: props.service.metricCpuUtilization({ period: cdk.Duration.minutes(5) }),
      threshold: 85,
      evaluationPeriods: 3,
      alarmDescription: 'Service CPU consistently high',
    }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic));
  }
}
```

---

## Deploy Target: Lambda (Serverless)

```typescript
// lib/lambda-service.ts
import * as cdk from 'aws-cdk-lib';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigw from 'aws-cdk-lib/aws-apigatewayv2';
import * as integrations from 'aws-cdk-lib/aws-apigatewayv2-integrations';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

export class LambdaServiceConstruct extends Construct {
  constructor(scope: Construct, id: string, props: { environment: string; databaseSecret: secretsmanager.ISecret }) {
    super(scope, id);

    const fn = new lambda.Function(this, 'Handler', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'dist/lambda.handler',
      code: lambda.Code.fromAsset('../', { exclude: ['node_modules', 'infra', '.git'] }),
      memorySize: props.environment === 'production' ? 512 : 256,
      timeout: cdk.Duration.seconds(30),
      environment: {
        NODE_ENV: props.environment,
        LOG_LEVEL: props.environment === 'production' ? 'info' : 'debug',
      },
    });

    props.databaseSecret.grantRead(fn);

    const api = new apigw.HttpApi(this, 'Api', {
      apiName: `${cdk.Stack.of(this).stackName}-api`,
      defaultIntegration: new integrations.HttpLambdaIntegration('LambdaIntegration', fn),
    });

    new cdk.CfnOutput(this, 'ApiUrl', { value: api.url! });
  }
}
```

---

## Usage Commands

```bash
# Install CDK dependencies
cd infra && npm install

# Synthesize CloudFormation template (validate)
npx cdk synth -c env=dev

# Diff — show what will change
npx cdk diff -c env=dev

# Deploy to dev
npx cdk deploy -c env=dev

# Deploy to production (requires approval)
npx cdk deploy -c env=production --require-approval broadening

# Destroy dev (cleanup)
npx cdk destroy -c env=dev
```

---

## CDK Pipeline (Self-Mutating CI/CD)

For teams that want CDK to manage its own pipeline:

```typescript
// bin/pipeline.ts
import * as cdk from 'aws-cdk-lib';
import { CodePipeline, CodePipelineSource, ShellStep } from 'aws-cdk-lib/pipelines';

const app = new cdk.App();
const pipelineStack = new cdk.Stack(app, '{Service}-Pipeline');

const pipeline = new CodePipeline(pipelineStack, 'Pipeline', {
  pipelineName: '{SERVICE}-deploy',
  synth: new ShellStep('Synth', {
    input: CodePipelineSource.gitHub('{ORG}/{REPO}', 'main'),
    commands: ['cd infra', 'npm ci', 'npx cdk synth'],
    primaryOutputDirectory: 'infra/cdk.out',
  }),
});

pipeline.addStage(new AppStage(app, 'Dev', { env: devConfig }));
pipeline.addStage(new AppStage(app, 'Production', { env: prodConfig }), {
  pre: [new pipelines.ManualApprovalStep('PromoteToProduction')],
});
```

This creates a self-mutating pipeline: push to main → pipeline updates itself → deploys infrastructure + app.
