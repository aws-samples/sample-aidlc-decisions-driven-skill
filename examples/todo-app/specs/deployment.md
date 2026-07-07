# Deployment: todo-app

## Summary
- **CI/CD**: GitHub Actions — auto-deploy dev on push, manual approval for production
- **Target**: ECS Fargate (AWS) — managed containers with ALB, VPC, auto-scaling
- **Strategy**: Rolling update — zero-downtime gradual replacement
- **Environments**: dev + production — auto promotion to dev, manual to prod
- **IaC**: Terraform — VPC, ECS, ALB, RDS, ECR, Secrets Manager
- **Secrets**: AWS Secrets Manager — injected at container start via task execution role
- **Rollback**: ECS circuit breaker — automatic rollback on health check failure
- **Verification**: ALB health check on /health endpoint

---

## Pipeline Architecture

### Stages

| # | Stage | Trigger | Purpose | Key Actions |
|---|---|---|---|---|
| 1 | Build | Push to main | Compile and package | Install deps, tsc, prisma generate |
| 2 | Test | After build | Verify correctness | Jest unit + integration, coverage gate >= 80% |
| 3 | Quality | After test | Code standards | ESLint, tsc --noEmit |
| 4 | Docker | After quality | Container image | Multi-stage build, push to ECR |
| 5 | Migrate (dev) | After docker | Schema updates | Run prisma migrate deploy against dev RDS |
| 6 | Deploy (dev) | After migrate | Release to dev | Update ECS task definition, rolling deploy |
| 7 | Verify (dev) | After deploy | Confirm health | Wait for ALB target healthy, curl /health |
| 8 | Deploy (prod) | Manual approval | Release to production | Update ECS task definition, rolling deploy |
| 9 | Verify (prod) | After deploy | Confirm health | Wait for ALB target healthy, curl /health |

### Flow Diagram

```
push to main ─► Build ─► Test ─► Quality ─► Docker (ECR) ─► Migrate (dev) ─► Deploy (dev) ─► Verify (dev)

tag v*.*.* ──────────────────────────────────► Manual Approval ─► Migrate (prod) ─► Deploy (prod) ─► Verify (prod)
```

---

## Target Infrastructure

### Topology

| Component | Service/Resource | Environment | Configuration |
|---|---|---|---|
| Application | ECS Fargate | dev, production | 256 CPU / 512 MB (dev), 512 CPU / 1024 MB (prod) |
| Load Balancer | ALB | dev, production | Public-facing, HTTPS (443), HTTP→HTTPS redirect |
| Database | RDS PostgreSQL 16 | dev, production | db.t4g.micro (dev), db.t4g.small (prod) |
| Container Registry | ECR | shared | Private repository, lifecycle policy (keep 10 images) |
| Networking | VPC | per environment | 2 public subnets, 2 private subnets, NAT Gateway |
| Secrets | AWS Secrets Manager | per environment | DATABASE_URL, API keys |
| DNS | Route 53 | production | Optional — A record alias to ALB |

### Environment Layout

| Environment | Purpose | Trigger | Auto-deploy | Protection |
|---|---|---|---|---|
| dev | Development/testing | Push to main | Yes | None |
| production | Live traffic | Version tag (v*.*.*) | No | Requires GitHub environment approval |

---

## Promotion Flow

```
dev (auto on push to main) ──── manual approval + version tag ────► production
```

- **Dev**: Every push to main builds, tests, pushes image to ECR, and deploys to dev ECS service
- **Production**: Triggered by version tag (v*.*.*); requires GitHub environment approval; deploys same image that passed dev verification

---

## Security & Secrets

### Secrets Required

| Secret | Purpose | Environments | Storage |
|---|---|---|---|
| `DATABASE_URL` | PostgreSQL connection string | dev, production | AWS Secrets Manager |
| `AWS_ACCESS_KEY_ID` | CI deployment credentials | CI only | GitHub Actions secrets |
| `AWS_SECRET_ACCESS_KEY` | CI deployment credentials | CI only | GitHub Actions secrets |
| `JWT_SECRET` | Token signing | dev, production | AWS Secrets Manager |

### Network & Access

- ECS tasks run in private subnets; no direct internet access except through NAT Gateway
- ALB in public subnets handles inbound traffic; forwards to ECS via target group
- RDS in private subnets; accessible only from ECS security group (port 5432)
- ECS task execution role pulls secrets from Secrets Manager at container start
- CI uses OIDC federation (preferred) or IAM user with minimal permissions: ECR push, ECS deploy, Secrets Manager read

---

## Operations Integration

### Health & Readiness

| Check | Endpoint/Method | Timeout | Failure Action |
|---|---|---|---|
| ALB Health | GET /health | 5s, interval 30s | Remove from target group, ECS replaces task |
| Container Health | HEALTHCHECK in Dockerfile | 10s | ECS marks task unhealthy |
| Startup | ECS task stabilization | 120s | Circuit breaker triggers rollback |

### Observability

- **Logging**: Structured JSON to stdout → CloudWatch Logs (via awslogs driver)
- **Metrics**: ECS/ALB CloudWatch metrics (CPU, memory, request count, 5xx rate)
- **Alerting**: CloudWatch Alarms on 5xx rate > 1% and CPU > 80% (manual setup post-deploy)

### Graceful Shutdown

- Signal: SIGTERM
- Grace period: 30 seconds (ECS `stopTimeout`)
- Drain: ALB deregistration delay 30s; Express server stops accepting new connections, finishes in-flight requests

---

## Rollback Strategy

- **Method**: ECS deployment circuit breaker (automatic)
- **Trigger**: If new tasks fail to stabilize (health check failures), ECS automatically rolls back to previous task definition
- **Steps**:
  1. ECS detects new tasks failing health checks
  2. Circuit breaker activates after threshold (default: 50% tasks unhealthy)
  3. ECS stops deploying new tasks, re-launches previous task definition
  4. Service stabilizes on previous version
  5. GitHub Actions reports deployment failure
- **Recovery time**: 2-5 minutes (depends on deregistration delay + task startup)
- **Data considerations**: Database migrations are forward-only; if a migration must be rolled back, create a new migration that reverses the change

---

## Database Migrations

- **Strategy**: Run before deploy (separate CI step)
- **Timing**: After Docker image push, before ECS service update
- **Command**: `npx prisma migrate deploy` (run via ECS RunTask or from CI with VPN/bastion access to RDS)
- **Failure handling**: Pipeline fails; ECS service update does not proceed. Fix migration and re-push.
- **Rollback**: Create a new reverse migration — Prisma does not support down migrations natively

---

## Files to Generate

| File | Purpose | Notes |
|---|---|---|
| `.github/workflows/deploy.yml` | CI/CD pipeline (build, test, deploy) | Combined CI + deploy workflow |
| `Dockerfile` | Multi-stage container build | Node 20 slim, non-root user, HEALTHCHECK |
| `.dockerignore` | Build context optimization | Exclude node_modules, .git, tests |
| `infra/main.tf` | Terraform provider + backend (S3) | AWS provider, S3 state backend |
| `infra/variables.tf` | Configurable values | Region, environment, instance sizes |
| `infra/outputs.tf` | Service URL, DB endpoint | ALB DNS, RDS endpoint |
| `infra/versions.tf` | Required providers | hashicorp/aws >= 5.0 |
| `infra/vpc.tf` | VPC + subnets + NAT | 2 AZ, public + private subnets |
| `infra/ecs.tf` | ECS cluster, service, task definition | Fargate, rolling deploy, circuit breaker |
| `infra/alb.tf` | ALB + target group + listeners | HTTPS redirect, health check config |
| `infra/rds.tf` | RDS PostgreSQL instance | Private subnet, security group |
| `infra/ecr.tf` | ECR repository + lifecycle | Keep 10 images, immutable tags |
| `infra/secrets.tf` | Secrets Manager resources | DATABASE_URL, JWT_SECRET placeholders |
| `infra/iam.tf` | Task execution role + task role | Secrets access, CloudWatch logs |
| `infra/environments/dev.tfvars` | Dev environment values | Smaller instances, relaxed settings |
| `infra/environments/production.tfvars` | Production environment values | Larger instances, deletion protection |
| `.env.dev.example` | Dev environment variable template | Placeholder values |
| `.env.production.example` | Production environment variable template | Secret references commented |
| `scripts/deploy.sh` | Manual deploy helper | For emergency bypassing CI |
| `scripts/rollback.sh` | Manual rollback helper | Force new deployment with previous task def |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| RDS connection exhaustion | Low | High | Connection pooling (Prisma default); task count limited |
| NAT Gateway single-AZ failure | Low | Medium | Single NAT for cost; upgrade to multi-AZ NAT for HA if needed |
| ECS task OOM kill | Medium | Low | Monitor memory metrics; increase task memory if needed |
| Terraform state corruption | Low | High | S3 backend with versioning + DynamoDB locking |
| Secret rotation breaks app | Low | Medium | Version secrets; test rotation in dev first |
| Migration blocks deploy | Low | Medium | Run migrations in separate step; fast-fail before deploy |

---

## Cost Estimate

| Resource | Environment | Estimated Monthly | Notes |
|---|---|---|---|
| ECS Fargate | dev | ~$10 | 256 CPU / 512 MB, 1 task running |
| ECS Fargate | production | ~$20 | 512 CPU / 1024 MB, 1-2 tasks |
| ALB | dev | ~$16 | Base cost + LCU charges (minimal) |
| ALB | production | ~$18 | Base cost + LCU charges |
| RDS (db.t4g.micro) | dev | ~$13 | Single-AZ, 20 GB gp3 |
| RDS (db.t4g.small) | production | ~$25 | Single-AZ, 20 GB gp3 |
| NAT Gateway | dev | ~$32 | Per-AZ fixed cost + data transfer |
| NAT Gateway | production | ~$32 | Per-AZ fixed cost + data transfer |
| ECR | shared | < $1 | Image storage |
| Secrets Manager | per env | < $2 | Per-secret monthly + API calls |
| CloudWatch Logs | per env | ~$3 | Log ingestion + storage |

**Total estimated**: ~$77 /month (dev only) to ~$170 /month (dev + production)

*Note: Estimates based on AWS us-east-1 pricing. NAT Gateway is the largest fixed cost — consider VPC endpoints for ECR/S3 to reduce data transfer charges. Actual costs depend on traffic and usage.*
