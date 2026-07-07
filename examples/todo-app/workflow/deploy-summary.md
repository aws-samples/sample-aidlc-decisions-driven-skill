# Deployment Summary — todo-app

**Date**: 2026-04-26T12:45:00Z
**CI/CD Platform**: GitHub Actions
**Deployment Target**: ECS Fargate (AWS)
**Strategy**: Rolling update
**IaC**: Terraform

## Pipeline

| Stage | Trigger | Actions |
|---|---|---|
| Build | Push to main | Install deps, compile TypeScript, run Prisma generate |
| Test | After build | Run Jest (unit + integration), check coverage >= 80% |
| Quality | After test | ESLint, tsc --noEmit |
| Docker | After quality | Multi-stage build, push to ECR |
| Migrate (dev) | After docker | Run prisma migrate deploy against dev RDS |
| Deploy (dev) | After migrate | Update ECS task definition, rolling deploy |
| Verify (dev) | After deploy | Wait for ALB target healthy, curl /health |
| Deploy (production) | Manual approval (tag v*.*.*) | Update ECS task definition, rolling deploy |
| Verify (production) | After deploy | Wait for ALB target healthy, curl /health |

## Environments

| Environment | Branch/Trigger | Promotion | URL |
|---|---|---|---|
| dev | main (push) | Auto on push | https://todo-app-dev.{domain} (ALB DNS) |
| production | tag v*.*.* | Manual approval | https://todo-app.{domain} (ALB DNS) |

## Infrastructure (Terraform)

| Resource | Type | Configuration |
|---|---|---|
| VPC | aws_vpc | 2 AZ, public + private subnets, NAT Gateway |
| ECS Cluster | aws_ecs_cluster | Fargate capacity provider |
| ECS Service | aws_ecs_service | Rolling deploy, circuit breaker enabled |
| ALB | aws_lb | Public-facing, HTTPS, health check on /health |
| RDS | aws_db_instance | PostgreSQL 16, private subnet, encrypted |
| ECR | aws_ecr_repository | Lifecycle policy (keep 10 images) |
| Secrets Manager | aws_secretsmanager_secret | DATABASE_URL, JWT_SECRET |
| IAM | aws_iam_role | Task execution role + task role |

## Files Generated

| File | Purpose |
|---|---|
| `.github/workflows/deploy.yml` | CI/CD pipeline definition |
| `Dockerfile` | Multi-stage container build (Node 20 slim) |
| `.dockerignore` | Build context optimization |
| `infra/main.tf` | Terraform provider + S3 backend |
| `infra/variables.tf` | Configurable values |
| `infra/outputs.tf` | ALB DNS, RDS endpoint |
| `infra/versions.tf` | Required providers (aws >= 5.0) |
| `infra/vpc.tf` | VPC + subnets + NAT Gateway |
| `infra/ecs.tf` | ECS cluster, service, task definition |
| `infra/alb.tf` | ALB + target group + listeners |
| `infra/rds.tf` | RDS PostgreSQL instance |
| `infra/ecr.tf` | ECR repository + lifecycle |
| `infra/secrets.tf` | Secrets Manager resources |
| `infra/iam.tf` | Task execution + task roles |
| `infra/environments/dev.tfvars` | Dev environment values |
| `infra/environments/production.tfvars` | Production environment values |
| `.env.dev.example` | Dev environment template |
| `.env.production.example` | Production environment template |
| `scripts/deploy.sh` | Manual deploy helper |
| `scripts/rollback.sh` | Manual rollback helper |

## Secrets Required

| Secret | Environments | Where to Configure |
|---|---|---|
| `DATABASE_URL` | dev, production | AWS Secrets Manager |
| `JWT_SECRET` | dev, production | AWS Secrets Manager |
| `AWS_ACCESS_KEY_ID` | CI only | GitHub Actions secrets |
| `AWS_SECRET_ACCESS_KEY` | CI only | GitHub Actions secrets |

## Rollback

- **Strategy**: ECS deployment circuit breaker (automatic)
- **Trigger**: New tasks fail health checks → ECS auto-rolls back to previous task definition
- **Manual**: `aws ecs update-service --force-new-deployment --task-definition <previous-td>`
- **Recovery time**: 2-5 minutes

## Post-Deployment Checklist

- [ ] Run `terraform init` and `terraform apply` for dev environment
- [ ] Configure GitHub Actions secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- [ ] Create secrets in AWS Secrets Manager (DATABASE_URL, JWT_SECRET)
- [ ] Push to main to trigger first dev deployment
- [ ] Verify ALB health check returns 200 on /health
- [ ] Run smoke test against dev environment
- [ ] Run `terraform apply` for production environment
- [ ] Configure GitHub environment protection rule for production
- [ ] Tag first production release (v1.0.0)
- [ ] Set up CloudWatch Alarms (5xx rate, CPU utilization)
