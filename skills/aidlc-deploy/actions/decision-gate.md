# Action: D5 Decision Gate — Deployment

## 1. Generate decisions file

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for output structure.
Write to `{WORKFLOW_DIR}/{feature}/decisions-deploy.md`.

### Context Detection (before generating questions)

Before presenting questions, detect:
- **Existing CI**: scan for `.github/workflows/`, `.gitlab-ci.yml`, `buildspec.yml`, `Jenkinsfile`
- **Existing IaC**: scan for `*.tf`, `cdk.json`, `serverless.yml`, `template.yaml` (SAM)
- **Git host**: infer from `.git/config` remote URL (github.com, gitlab.com, codecommit)
- **Cloud signals**: scan for AWS SDK usage, GCP client libs, Azure SDK in dependencies
- **Container signals**: existing `Dockerfile`, `docker-compose.yml`

Use detected context to pre-select recommendations.

### Questions

```markdown
### D5-1: CI/CD Platform
**Question**: Which CI/CD platform will run your pipeline?
- 1) GitHub Actions **(Recommended — detected GitHub repo)**
- 2) GitLab CI
- 3) AWS CodePipeline + CodeBuild
- 4) Other (please specify): _______

**Answer**: 

---

### D5-2: Deployment Target
**Question**: Where will this service run in production?
- 1) Docker → Cloud Run (GCP) — auto-scaling managed containers, pay-per-request
- 2) Docker → ECS Fargate (AWS) — managed containers with ALB, VPC, auto-scaling **(Recommended for AWS)**
- 3) Docker → Kubernetes (EKS/GKE/AKS) — full orchestration, complex but flexible
- 4) Serverless → Lambda / Cloud Functions — event-driven, no containers
- 5) Static → S3 + CloudFront / Vercel / Netlify — frontend only
- 6) VM → EC2 / Compute Engine — traditional deployment
- 7) Other (please specify): _______

**Answer**: 

---

### D5-3: Deployment Strategy
**Question**: How should new versions roll out?
- 1) Recreate — stop old, start new (simple, brief downtime) **(Recommended for dev/simple)**
- 2) Rolling update — gradual replacement, zero downtime **(Recommended for production APIs)**
- 3) Blue-green — parallel environments, instant switch
- 4) Canary — gradual traffic shift (1% → 10% → 100%)
- 5) Other (please specify): _______

**Answer**: 

---

### D5-4: Environments
**Question**: Which environments do you need?
- 1) dev + production **(Recommended for solo/small teams)**
- 2) dev + staging + production **(Recommended for teams with QA)**
- 3) dev + staging + production + preview (per-PR)
- 4) Other (please specify): _______

**Answer**: 

---

### D5-5: Environment Promotion
**Question**: How are deployments promoted between environments?
- 1) Auto-deploy to dev on push to main; manual approval for production **(Recommended)**
- 2) Auto-deploy to all environments on push (dev → staging → production pipeline)
- 3) Manual trigger for all environments
- 4) Other (please specify): _______

**Answer**: 

---

### D5-6: Secrets Management
**Question**: How are secrets and credentials handled?
- 1) Platform-native — GitHub Secrets / GitLab Variables **(Recommended for simple)**
- 2) Cloud secret manager — AWS Secrets Manager / GCP Secret Manager **(Recommended for production)**
- 3) HashiCorp Vault
- 4) Other (please specify): _______

**Answer**: 

---

### D5-7: Infrastructure as Code
**Question**: Should infrastructure be provisioned alongside the app?
- 1) None — use platform UI/CLI manually, deploy app code only **(Recommended for simple/prototype)**
- 2) Terraform — declarative, multi-cloud, state-managed **(Recommended for production)**
- 3) AWS CDK (TypeScript) — programmatic, type-safe, AWS-native
- 4) Pulumi — programmatic, multi-cloud, multi-language
- 5) CloudFormation / SAM — AWS-native YAML/JSON
- 6) Other (please specify): _______

**Answer**: 

---

### D5-8: Rollback Strategy
**Question**: How do you recover from a bad deployment?
- 1) Redeploy previous version (CI/CD re-runs with previous image/artifact) **(Recommended)**
- 2) Platform-native rollback (Cloud Run revision, ECS previous task def, K8s rollout undo)
- 3) Blue-green switch (instant traffic shift to previous environment)
- 4) Other (please specify): _______

**Answer**: 

---

### D5-9: Database Migrations
**Question**: How should database schema changes be deployed?
- 1) Run migrations in CI before app deploy — fail pipeline if migration fails **(Recommended)**
- 2) Run migrations on app startup — app handles schema changes
- 3) Manual migrations — DBA applies changes separately
- 4) No database / no migrations needed
- 5) Other (please specify): _______

**Answer**: 

---

### D5-10: Post-Deploy Verification
**Question**: How do you verify a deployment succeeded?
- 1) Health check — verify /health endpoint responds after deploy **(Recommended minimum)**
- 2) Smoke tests — run critical path tests against deployed environment
- 3) Full E2E suite — run complete test suite against deployed environment
- 4) Traffic monitoring — watch error rates for 5 minutes after deploy
- 5) Other (please specify): _______

**Answer**: 
```

**Recommendation logic** (use detected context):
- Git host = github.com → recommend GitHub Actions
- AWS SDK in deps → recommend ECS Fargate + Secrets Manager + CDK/Terraform
- GCP client libs in deps → recommend Cloud Run + GCP Secret Manager + Terraform
- Solo dev + simple app → recommend recreate + dev+production + None IaC
- Team + production service → recommend rolling + dev+staging+production + Terraform/CDK
- Existing IaC detected → recommend "extend existing" (match detected tool)

**Cloud provider inference from D3**: If D3 choices (from manifest `decisions.design`) include cloud-specific services (DynamoDB, SQS, Lambda → AWS; Cloud SQL, Firestore, Pub/Sub → GCP), infer the target cloud. Skip deploy target options for other clouds. Note in the decisions file: "Inferred from D3: {cloud}."

## 2. Present

```
📍 D5 — Deployment Decisions

- **Detected**: [existing CI/IaC/cloud signals — or "no existing config"]
- **Decisions**: 10 questions covering platform, target, strategy, IaC, and operations

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-deploy.md`, fill answers, say "done"
🤖 Or say "use recommendations" to auto-fill

---
🔲 **Your turn**:
- ✏️ Fill answers and say "done"
- 🤖 "use recommendations"
- ❓ "explain [question]" — get more context
```

**STOP — do NOT continue until user responds.**

When user says "done" or "use recommendations":
- If "use recommendations": fill every `**Answer**:` field with the recommended option
- If "done": read the user's answers from the `**Answer**:` fields. If any are blank → list the unanswered questions and **STOP** — ask the user to fill them or say "use recommendations" for the rest. Do not proceed with blanks.
- **Both paths**: populate the Decisions Summary section from the answers (one line per decision). Validation and manifest storage (step 4) read ONLY that section.
- Proceed to validation

## 3. Validate for conflicts

| Conflict | Severity | Condition |
|---|---|---|
| Platform unsupported target | 🔴 Critical | CI can't deploy to target (e.g., GHA → on-prem without self-hosted runners) |
| Canary without traffic control | 🟡 Major | Canary strategy but target doesn't support traffic splitting (plain ECS recreate) |
| Environment overkill | 🟢 Minor | Solo developer with 3+ environments |
| No rollback + production | 🟡 Major | Production deployment without rollback strategy |
| IaC without cloud target | 🟡 Major | IaC requested but target is "static" or "other" without cloud |
| Secrets gap | 🔴 Critical | Production deploy without secrets management |
| Migration strategy mismatch | 🟡 Major | "Run on startup" + serverless (cold starts would run migrations repeatedly) |
| K8s without IaC | 🟢 Minor | Kubernetes target without Terraform/CDK (manual cluster management) |

Present conflicts by severity. Offer resolution options.

## 4. Store decisions

Update manifest:
```yaml
decisions.deploy:
  ci-platform: "{value}"
  target: "{value}"
  strategy: "{value}"
  environments: "{value}"
  promotion: "{value}"
  iac: "{value}"
  secrets: "{value}"
  rollback: "{value}"
  migrations: "{value}"
  verification: "{value}"
```

## 5. Proceed

Load `{SKILL_DIR}/actions/plan.md`.

## 6. Audit entry

```
### [{ISO timestamp}] Deploy: Decision Gate

**Phase**: deploy
**Action**: decision-gate
**Artifacts**: decisions-deploy.md
**Outcome**: D5 completed. CI: {platform}, Target: {target}, Strategy: {strategy}, IaC: {iac}. {N} conflicts found, {M} resolved.
```
