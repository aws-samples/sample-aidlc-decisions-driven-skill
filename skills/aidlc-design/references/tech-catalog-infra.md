# Technology Catalog — Infrastructure & Operations

> Load ONLY if cloud-deployed with provisioned resources.

## Infrastructure & Deployment

- **Cloud Provider**: AWS, Azure, GCP, self-hosted, hybrid
- **Compute Platform**: Containers (ECS/EKS), Serverless (Lambda), VMs (EC2), PaaS (Heroku)
- **Container Orchestration**: ECS, EKS/Kubernetes, Docker Compose, none
- **CI/CD Tool**: GitHub Actions, GitLab CI, AWS CodePipeline, Jenkins, CircleCI
- **Artifact Registry**: ECR, Docker Hub, GitHub Packages, Artifactory

## Observability & Operations

- **Logging Destination**: CloudWatch, ELK Stack, Datadog, Splunk, local files
- **Metrics Collection**: CloudWatch Metrics, Prometheus, Datadog, New Relic, none
- **Distributed Tracing**: AWS X-Ray, Jaeger, Zipkin, Datadog APM, none for MVP
- **Error Tracking**: Sentry, Rollbar, Bugsnag, CloudWatch, none
- **Alerting**: CloudWatch Alarms, PagerDuty, Opsgenie, email, none

## Infrastructure as Code

- **IaC Tool**: AWS CDK, Terraform, CloudFormation, Pulumi, SST, Serverless Framework, none
- **IaC Language** (if CDK/Pulumi): TypeScript, Python, Java, Go, C#
- **State Management** (if Terraform): S3 + DynamoDB, Terraform Cloud, local, GitLab-managed
- **Environment Strategy**: Separate stacks per environment, parameterized single stack, account-per-environment
- **Module/Construct Strategy**: Custom constructs/modules, community constructs, L1/L2/L3 (CDK), monolithic template
