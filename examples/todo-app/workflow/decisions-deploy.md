# Deploy Decisions

## Context Summary
- **Project**: Greenfield Todo App
- **Stack**: TypeScript / Express / PostgreSQL / Prisma
- **Build**: Passing (24 tests, 92% coverage)
- **Team Size**: Solo
- **Complexity**: Low

---

## Decision Questions

### D5-1: CI/CD Platform
**Question**: Which CI/CD platform for automated build and deployment?
- 1) GitHub Actions — native to GitHub, free for public repos **(Recommended — detected GitHub repo)**
- 2) GitLab CI — integrated with GitLab, powerful pipelines
- 3) AWS CodePipeline + CodeBuild — AWS-native, tight IAM integration
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-2: Deployment Target
**Question**: Where will the application be deployed?
- 1) Docker → ECS Fargate (AWS) — managed containers with ALB, VPC, auto-scaling **(Recommended for AWS)**
- 2) Docker → Cloud Run (GCP) — serverless containers, scale to zero
- 3) Docker → Kubernetes (EKS/GKE/AKS) — full orchestration, complex
- 4) Serverless → Lambda + API Gateway — event-driven, no containers
- 5) Static → S3 + CloudFront — frontend only
- 6) Other (please specify): _______

**Answer**: 1

---

### D5-3: Deployment Strategy
**Question**: How should new versions be rolled out?
- 1) Rolling update — gradual replacement, zero downtime **(Recommended for production APIs)**
- 2) Recreate — stop old, start new (simple, brief downtime)
- 3) Blue/Green — parallel environments, instant switchover
- 4) Canary — gradual traffic shift, early error detection
- 5) Other (please specify): _______

**Answer**: 1

---

### D5-4: Environments
**Question**: Which deployment environments do you need?
- 1) dev + production (minimum viable) **(Recommended for solo/small teams)**
- 2) dev + staging + production
- 3) dev + staging + production + preview per PR
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-5: Environment Promotion
**Question**: How should deployments promote between environments?
- 1) Automatic — push to main deploys to dev, tag deploys to production **(Recommended)**
- 2) Manual gates — require approval before each environment
- 3) Scheduled — deploy to production on a schedule
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-6: Secrets Management
**Question**: How will secrets (DB credentials, API keys) be managed?
- 1) AWS Secrets Manager — cloud-native, rotation support, ECS integration **(Recommended for AWS)**
- 2) CI/CD platform secrets (GitHub Actions secrets)
- 3) AWS Systems Manager Parameter Store — simpler, cheaper, good for config
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-7: Infrastructure as Code
**Question**: Use IaC for infrastructure provisioning?
- 1) Terraform — declarative, multi-cloud, state-managed **(Recommended for production)**
- 2) AWS CDK (TypeScript) — programmatic, type-safe, AWS-native
- 3) CloudFormation / SAM — AWS-native YAML/JSON
- 4) None — manual setup via AWS console
- 5) Other (please specify): _______

**Answer**: 1

---

### D5-8: Rollback Strategy
**Question**: How to handle failed deployments?
- 1) ECS circuit breaker — automatic rollback on deployment failure **(Recommended)**
- 2) Redeploy previous task definition — manual rollback via CI
- 3) Blue/Green switch — redirect traffic to previous target group
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-9: Database Migrations
**Question**: How should database migrations run during deployment?
- 1) Before deploy — run as a separate CI step **(Recommended)**
- 2) During deploy — run as ECS task before service update
- 3) Manual — run migrations manually before deploying
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-10: Post-Deploy Verification
**Question**: How to verify successful deployment?
- 1) Health check endpoint — ALB target group health check on /health **(Recommended minimum)**
- 2) Smoke tests — run critical path tests against deployed environment
- 3) E2E tests — full end-to-end test suite
- 4) None — rely on CloudWatch monitoring and alerts
- 5) Other (please specify): _______

**Answer**: 1

---

## Decisions Summary
- D5-1 CI/CD Platform: GitHub Actions
- D5-2 Deployment Target: ECS Fargate (AWS)
- D5-3 Deployment Strategy: Rolling update
- D5-4 Environments: dev + production
- D5-5 Promotion: Automatic (push→dev, tag→production)
- D5-6 Secrets: AWS Secrets Manager
- D5-7 IaC: Terraform
- D5-8 Rollback: ECS circuit breaker (automatic)
- D5-9 Migrations: Before deploy (CI step)
- D5-10 Verification: ALB health check endpoint

---

**Instructions**: Fill in your answers above and respond with "done"
