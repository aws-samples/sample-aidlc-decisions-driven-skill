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
- 1) GitHub Actions — native to GitHub, free for public repos **(Recommended)**
- 2) GitLab CI — integrated with GitLab, powerful pipelines
- 3) CircleCI — fast, good caching, Docker-native
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-2: Deployment Target
**Question**: Where will the application be deployed?
- 1) Google Cloud Run — serverless containers, scale to zero **(Recommended)**
- 2) AWS ECS Fargate — managed containers, AWS ecosystem
- 3) Kubernetes (GKE/EKS) — full orchestration, complex
- 4) Railway/Render — simple PaaS, minimal config
- 5) Other (please specify): _______

**Answer**: 1

---

### D5-3: Deployment Strategy
**Question**: How should new versions be rolled out?
- 1) Recreate — stop old, start new (simple, brief downtime) **(Recommended)**
- 2) Rolling update — gradual replacement, zero downtime
- 3) Blue/Green — parallel environments, instant switchover
- 4) Canary — gradual traffic shift, early error detection
- 5) Other (please specify): _______

**Answer**: 1

---

### D5-4: Environments
**Question**: Which deployment environments do you need?
- 1) dev + production (minimum viable) **(Recommended)**
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
- 1) CI/CD platform secrets (GitHub Actions secrets) **(Recommended)**
- 2) Cloud provider secret manager (GCP Secret Manager, AWS Secrets Manager)
- 3) Environment variables in deployment platform
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-7: Infrastructure as Code
**Question**: Use IaC for infrastructure provisioning?
- 1) None — manual setup via cloud console (acceptable for simple projects) **(Recommended)**
- 2) Terraform — declarative, multi-cloud
- 3) AWS CDK — imperative, TypeScript, AWS-native
- 4) Pulumi — imperative, multi-language, multi-cloud
- 5) Other (please specify): _______

**Answer**: 1

---

### D5-8: Rollback Strategy
**Question**: How to handle failed deployments?
- 1) Redeploy previous revision — Cloud Run keeps revision history **(Recommended)**
- 2) Git revert + redeploy — roll back code, trigger new deploy
- 3) Blue/Green switch — redirect traffic to previous environment
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-9: Database Migrations
**Question**: How should database migrations run during deployment?
- 1) Before deploy — run as a separate CI step **(Recommended)**
- 2) During deploy — run as container startup command
- 3) Manual — run migrations manually before deploying
- 4) Other (please specify): _______

**Answer**: 1

---

### D5-10: Post-Deploy Verification
**Question**: How to verify successful deployment?
- 1) Health check endpoint — verify /health returns 200 **(Recommended)**
- 2) Smoke tests — run critical path tests against deployed app
- 3) E2E tests — full end-to-end test suite
- 4) None — rely on monitoring and alerts
- 5) Other (please specify): _______

**Answer**: 1

---

## Decisions Summary
- D5-1 CI/CD Platform: GitHub Actions
- D5-2 Deployment Target: Google Cloud Run (Docker)
- D5-3 Deployment Strategy: Recreate
- D5-4 Environments: dev + production
- D5-5 Promotion: Automatic (push→dev, tag→production)
- D5-6 Secrets: GitHub Actions secrets
- D5-7 IaC: None
- D5-8 Rollback: Redeploy previous Cloud Run revision
- D5-9 Migrations: Before deploy (CI step)
- D5-10 Verification: Health check endpoint

---

**Instructions**: Fill in your answers above and respond with "done"
