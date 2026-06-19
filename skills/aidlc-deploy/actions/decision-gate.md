# Action: D5 Decision Gate — Deployment

## 1. Generate decisions file

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

Write to `{WORKFLOW_DIR}/{feature}/decisions-deploy.md`:

### Questions

| # | Question | Context | Recommendations |
|---|---|---|---|
| 1 | **CI/CD Platform** — Which CI/CD platform will run your pipeline? | Detected: {existing CI if found} | Match existing platform; otherwise GitHub Actions for GitHub repos, GitLab CI for GitLab repos |
| 2 | **Deployment Target** — Where does the application run? | Stack: {from context-summary} | Based on architecture: containers → ECS/K8s, serverless → Lambda/Cloud Functions, static → S3/CloudFront/Vercel |
| 3 | **Deployment Strategy** — How should new versions roll out? | Architecture: {from context-summary} | Simple apps → recreate; APIs with uptime requirements → blue-green or rolling; high-traffic → canary |
| 4 | **Environments** — Which environments do you need? | Team size: {from manifest} | Solo/small → dev + production; medium/large → dev + staging + production |
| 5 | **Environment Promotion** — How are deployments promoted between environments? | — | Auto-deploy to dev on push; manual approval for staging/production |
| 6 | **Secrets Management** — How are secrets and credentials handled? | CI platform: {from Q1} | Platform-native: GitHub Secrets, GitLab Variables, AWS Secrets Manager |
| 7 | **Rollback Strategy** — How do you recover from a bad deployment? | Deploy strategy: {from Q3} | Blue-green → instant switch; rolling → redeploy previous; canary → halt rollout |
| 8 | **Monitoring & Alerts** — What signals indicate deployment health? | — | HTTP 5xx rate, response time p95, error log spike, health endpoint |
| 9 | **Branch Strategy** — Which branches trigger which environments? | — | `main` → production, `develop`/`staging` → staging, feature branches → dev/preview |
| 10 | **Infrastructure as Code** — Should infrastructure be provisioned alongside the app? | Existing IaC: {detected or "none"} | If existing IaC → extend; greenfield with cloud target → generate Terraform/CDK; simple deploys → skip |

## 2. Present

```
📍 D5 — Deployment Decisions

Generated: `{WORKFLOW_DIR}/{feature}/decisions-deploy.md`

Fill in your answers (or say "use recommendations" for suggested defaults).
I'll validate for conflicts once you're done.

🔲 **Your turn**:
- ✏️ Fill answers in the file
- 💡 "use recommendations" — auto-fill with suggested values
- ❓ "explain [question]" — get more context on a specific question
```

**STOP — do NOT continue until user responds.**

## 3. Validate for conflicts

After answers are provided, check for conflicts:

| Conflict | Severity | Condition |
|---|---|---|
| Platform mismatch | 🔴 Critical | CI platform doesn't support deployment target (e.g., GitHub Actions → on-prem without self-hosted runners) |
| Strategy/target mismatch | 🟡 Major | Canary deployment without load balancer or traffic management capability |
| Environment overkill | 🟢 Minor | Solo developer with 3+ environments |
| Missing rollback | 🟡 Major | No rollback strategy with production deployment |
| IaC without target | 🟡 Major | IaC generation requested but no cloud target specified |
| Secrets gap | 🔴 Critical | Production deployment without secrets management strategy |
| Branch/env mismatch | 🟢 Minor | More branch triggers than environments |

Present conflicts (if any) grouped by severity. Offer resolution options for each.

## 4. Store decisions

After validation (or user says "skip validation"):

Update manifest:
```yaml
decisions.deploy: { ci-platform: "{value}", target: "{value}", strategy: "{value}", environments: "{value}" }
```

## 5. Proceed

Load `{SKILL_DIR}/actions/generate.md`.

## 6. Audit entry

```
### [{ISO timestamp}] Deploy: Decision Gate

**Phase**: deploy
**Action**: decision-gate
**Artifacts**: decisions-deploy.md
**Outcome**: D5 completed. {N} conflicts found, {M} resolved. CI: {platform}, Target: {target}, Strategy: {strategy}.
```
