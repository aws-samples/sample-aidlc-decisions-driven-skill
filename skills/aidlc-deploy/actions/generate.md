# Action: Generate Pipeline and Configs

## 1. Load decisions, deployment spec, and references

Read D5 answers from manifest `decisions.deploy`. Read the approved deployment specification from `{SPECS_DIR}/{feature}/deployment.md`. Load references conditionally:

| D5 Answer | Load Reference |
|---|---|
| CI = GitHub Actions | `{REFS}/platform-github-actions.md` (stack section + target section only) |
| CI = GitLab CI | `{REFS}/platform-gitlab-ci.md` (stack section + target section only) |
| CI = CodePipeline | `{REFS}/platforms.md` (CodePipeline section) |
| IaC = Terraform | `{REFS}/iac-terraform.md` (target section + database section) |
| IaC = CDK | `{REFS}/iac-cdk.md` (target section + database section) |
| IaC = None | Skip IaC references |

**Stack-aware selective reading**: read ONLY the section matching `context-summary.stack`:
- TypeScript/Node → "Stack: Node.js / TypeScript" section
- Python → "Stack: Python / FastAPI" section
- Java/Kotlin → "Stack: Java / Spring Boot" section
- Go → "Stack: Go" section

**Target-aware selective reading**: read ONLY the deploy target section matching D5-2 answer.

Also read: `design/operations.md` (if exists), `design/implementation.md`, version map from manifest.

**Plan conformance**: The approved `deployment.md` is the authoritative source for what to generate. Follow its pipeline architecture, infrastructure topology, environment layout, and file list. Do not deviate from the spec without user approval. If implementation reveals that the spec needs adjustment, present the discrepancy and wait for user confirmation before proceeding.

## 1.5. Version resolution for deploy tooling

Resolve current versions for deploy-specific tools via web search:
- **GHA actions**: `actions/checkout`, `actions/setup-node`, `actions/upload-artifact`, cloud auth actions — verify current `@v{N}` tags
- **Terraform providers**: `hashicorp/aws`, `hashicorp/google` — verify current major version from registry.terraform.io
- **CDK**: `aws-cdk-lib` — verify current version from npm
- **Docker base images**: `node:{version}-slim`, `python:{version}`, etc. — use versions from design manifest version map
- **CI service images**: `postgres`, `redis` — use versions from design manifest version map

**Fallback**: if web search unavailable, use versions shown in reference templates as defaults. Mark with `# version unverified` comment in generated files.

**Rules**: Same as design Step 0.5 — prefer LTS, don't pick bleeding-edge, only resolve tools actually being used.

## 2. Generate CI/CD pipeline

Based on D5-1 (CI platform), generate the pipeline config using the loaded platform reference as the template source.

**Substitution rules** — replace placeholders in templates:
- `{NODE_VERSION}`, `{PYTHON_VERSION}`, etc. → from manifest `versions.map`
- `{DB_VERSION}` → from manifest `versions.map` (database engine)
- `{SERVICE}` → from manifest `feature` or `context-summary.feature` (kebab-case)
- `{REGION}` → from D5 answers or default for target cloud
- `{PORT}` → from `design/operations.md` or `design/implementation.md`
- `{CLUSTER}`, `{NAMESPACE}`, `{REPO}` → derived from service name + environment

**Pipeline must include**:
- Build step (matching what aidlc-build verified)
- Full test suite (unit + integration)
- Quality gates (lint, type-check, security scan)
- Deploy per environment (from D5-4)
- Promotion gates (from D5-5): auto or manual
- Database migration step (from D5-9) — before or during deploy
- Post-deploy verification (from D5-10) — health check, smoke test, or E2E

**Output paths**:
- GitHub Actions: `.github/workflows/ci.yml` + `.github/workflows/deploy.yml` (or combined)
- GitLab CI: `.gitlab-ci.yml`
- CodePipeline: `buildspec.yml`

## 3. Generate Dockerfile (if container target)

If D5-2 is container-based (Cloud Run, ECS, K8s) and no Dockerfile exists:

Generate using the Dockerfile template from the platform reference. Apply:
- Multi-stage build (builder → production)
- Non-root user
- HEALTHCHECK from `design/operations.md` health endpoint
- STOPSIGNAL SIGTERM
- `.dockerignore` for build context optimization

**Output**: `Dockerfile` + `.dockerignore` at project root.

## 4. Generate environment configs

For each environment in D5-4:
- `.env.{environment}.example` — all env vars from `design/operations.md` Configuration section
- Mark sensitive vars with comments: `# Set in CI/CD secrets — do not commit`
- Include: APP_ENV, PORT, LOG_LEVEL, DATABASE_URL, plus any from operations/implementation

## 5. Generate IaC (conditional)

**Skip if** D5-7 = "None".

If IaC selected, generate infrastructure files using the loaded IaC reference:

### Terraform (D5-7 = Terraform)

Generate `infra/` directory:
- `main.tf` — provider, backend (S3/GCS based on target cloud)
- `variables.tf` — all configurable values
- `outputs.tf` — service URL, database endpoint
- `versions.tf` — required providers
- Target-specific resource file (e.g., `ecs.tf`, `cloud-run.tf`)
- `database.tf` — if data model exists in design
- `monitoring.tf` — if `design/operations.md` exists and observability ≥ Standard
- `environments/dev.tfvars` + `environments/production.tfvars`

### CDK (D5-7 = CDK)

Generate `infra/` directory:
- `bin/app.ts` — CDK app entry with environment switching
- `lib/app-stack.ts` — main stack composing constructs
- `lib/service.ts` — container or lambda service construct
- `lib/database.ts` — if data model exists
- `lib/networking.ts` — VPC construct
- `lib/monitoring.ts` — if `design/operations.md` exists and observability ≥ Standard
- `config/dev.ts` + `config/production.ts`
- `cdk.json` + `package.json` + `tsconfig.json`

### IaC generation rules
- Use environment-aware sizing (dev=small, production=larger)
- Enable deletion protection for production resources
- Use secret management per D5-6 choice
- Include health probes from `design/operations.md`
- Include monitoring/alerting from `design/operations.md` (if observability ≥ Standard)
- All resources tagged with project + environment + "ManagedBy: {iac-tool}"

## 6. Generate deployment scripts

Generate helper scripts:
- `scripts/deploy.sh` — manual deploy for emergencies (bypassing CI)
- `scripts/rollback.sh` — rollback per D5-8 strategy (platform-specific commands)

Scripts should include:
- Pre-flight checks (auth configured, required tools installed)
- The actual deploy/rollback command
- Post-deploy health check

## 7. Apply operations design (from design/operations.md)

If `design/operations.md` exists, ensure all generated files incorporate:
- **Health probes**: Dockerfile HEALTHCHECK, K8s probes, Cloud Run probes, ALB health checks
- **Graceful shutdown**: STOPSIGNAL, terminationGracePeriodSeconds, stop timeout
- **Log routing**: LOG_LEVEL env var, structured JSON to stdout, platform log driver config
- **Metrics**: /metrics endpoint exposure (Prometheus annotations for K8s, sidecar note for others)
- **Error tracking**: SENTRY_DSN or equivalent in secrets + env config
- **Alerting** (if Full): include alerting configuration in generated IaC/pipeline where possible; note remaining manual setup steps for finalize summary

## 8. Present generated files

```
📍 Deployment Configuration Generated

- **CI/CD**: {platform} — `{pipeline path}`
- **Target**: {deploy target}
- **Strategy**: {strategy}
- **IaC**: {tool} — `infra/` ({N} files) | None
- **Environments**: {env list}
- **Verification**: {from D5-10}

Files created:
- `{pipeline config}` — CI/CD pipeline
- `Dockerfile` + `.dockerignore` — container build (if applicable)
- `.env.*.example` — environment templates
- `infra/` — infrastructure code (if IaC selected)
- `scripts/deploy.sh`, `scripts/rollback.sh` — helper scripts

---
🔲 **Your turn**:
- ✅ "approve" — finalize deployment configuration
- 🔍 "show [file]" — inspect a generated file
- 🔧 "edit [file]" — modify a specific file
- ➕ "add [component]" — add monitoring, alerts, or additional config
```

**STOP and wait.**

On "edit": apply changes, re-present.
On "approve": load `{SKILL_DIR}/actions/finalize.md`.

## 9. Audit entry

```
### [{ISO timestamp}] Deploy: Generation

**Phase**: deploy
**Action**: generation
**Artifacts**: {list all generated files}
**Outcome**: Generated {N} files. CI: {platform}, Target: {target}, IaC: {tool or "None"}. {M} environments configured.
```
