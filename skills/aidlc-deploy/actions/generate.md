# Action: Generate Pipeline and Configs

## 1. Read decisions

Load `{WORKFLOW_DIR}/{feature}/decisions-deploy.md` for D5 answers:
- CI/CD platform → determines config format
- Deployment target → determines deploy steps
- Environments → determines environment files
- Secrets → determines secret references
- Branch strategy → determines triggers

## 2. Generate CI/CD pipeline

Based on CI platform decision, generate the appropriate config file:

### GitHub Actions
Path: `.github/workflows/deploy.yml`

Structure:
```yaml
name: Deploy
on:
  push:
    branches: [{branch triggers from D5}]
  pull_request:
    branches: [main]

env:
  # Project-specific environment variables

jobs:
  build:
    # Build step (mirrors what aidlc-build verified)
  test:
    # Full test suite
  quality:
    # Lint, type-check, security scan
  deploy-{env}:
    # Per-environment deploy jobs with appropriate gates
```

### GitLab CI
Path: `.gitlab-ci.yml`

### AWS CodePipeline / CodeBuild
Path: `buildspec.yml` + `pipeline.yml` (or CDK if IaC selected)

### Other platforms
Generate the equivalent config following platform conventions.

---

## 3. Generate environment configs

For each environment specified in D5:

### Environment variable template
Path: `.env.{environment}.example` (never actual secrets)

```bash
# {Environment} Configuration
# Copy to .env.{environment} and fill in actual values

APP_ENV={environment}
APP_PORT=3000
DATABASE_URL=  # Set in CI/CD secrets
API_KEY=       # Set in CI/CD secrets
```

### Environment-specific overrides (if applicable)
- Kubernetes: `k8s/{environment}/` with kustomize overlays or Helm values
- Docker Compose: `docker-compose.{environment}.yml`
- Serverless: `serverless-{environment}.yml` or stage config
- Terraform: `environments/{environment}/terraform.tfvars`

---

## 4. Generate deployment scripts (if applicable)

For targets that benefit from deploy scripts:

Path: `scripts/deploy.sh` (or platform equivalent)

Include:
- Pre-deploy health check
- Deployment execution
- Post-deploy smoke test
- Rollback trigger on failure

---

## 5. Generate Dockerfile / container config (if applicable)

If deployment target is container-based and no Dockerfile exists:

Path: `Dockerfile`

Follow best practices:
- Multi-stage build (build → production)
- Non-root user
- Minimal base image
- Health check instruction
- `.dockerignore` for build context optimization

---

## 5.5. Apply operations design to deployment config (conditional)

**Skip this step if**: `design/operations.md` does not exist.

If `design/operations.md` exists, read it and apply operational settings to the generated deployment files:

### Container health probes (if Dockerfile generated or K8s target)

Read the Health & Readiness section from `design/operations.md` and generate:

**Dockerfile HEALTHCHECK** (if Dockerfile generated):
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:{PORT}/health || exit 1
```

**Kubernetes probes** (if K8s deployment target):
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: {PORT}
  initialDelaySeconds: 10
  periodSeconds: 30
  timeoutSeconds: 3
readinessProbe:
  httpGet:
    path: /health/ready
    port: {PORT}
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 3
```

**Cloud Run / ECS / App Runner** (if applicable):
- Configure health check path and interval per platform conventions
- Set startup grace period from `design/operations.md` configuration (drain delay)

### Graceful shutdown configuration

Read the Graceful Shutdown section and apply:

**Kubernetes**: Set `terminationGracePeriodSeconds` to match the shutdown timeout from operations.md (default 30s).

**Docker**: Ensure `STOPSIGNAL SIGTERM` is set (default, but be explicit).

**Cloud Run**: Set `--timeout` for request draining per the configured shutdown timeout.

**ECS**: Set `stopTimeout` in task definition.

### Log routing

Read the Logging section from `design/operations.md` and configure log delivery:

| Platform | Log Configuration |
|---|---|
| GitHub Actions + Cloud Run | `--set-env-vars LOG_LEVEL=info` in deploy step |
| AWS ECS | `awslogs` log driver in task definition → CloudWatch |
| Kubernetes | Structured JSON to stdout → collected by cluster log agent |
| Docker Compose | JSON file driver with log rotation options |

Add LOG_LEVEL to environment config template (`.env.{environment}.example`).

### Metrics endpoint exposure (if D3 observability ≥ Standard)

If the app exposes `/metrics`:
- **Kubernetes**: Add annotations for Prometheus scraping:
  ```yaml
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "{PORT}"
  ```
- **Cloud Run / ECS**: Document that metrics need a sidecar or push-based export (OTLP)
- **Docker Compose**: Add Prometheus service to compose file (optional, for local dev)

### Error tracking environment variables (if D3 error tracking = Dedicated)

Add error tracking service DSN/token to:
- Secret references in pipeline config (e.g., `${{ secrets.SENTRY_DSN }}`)
- Environment template files (`.env.{environment}.example`)
- Source map upload step in CI pipeline (for JavaScript/TypeScript services)

### Alerting integration (if D3 observability = Full)

Add alerting configuration notes to `deploy-summary.md`:
- Required external setup: alert notification channel (Slack webhook, PagerDuty key, etc.)
- Recommended alert rules from `design/operations.md` Alerting section
- Link to platform-specific alerting docs

---

## 6. Present generated files

```
📍 Deployment Configuration Generated

**CI/CD**: {platform} — `{pipeline config path}`
**Target**: {deployment target}
**Strategy**: {strategy}
**Environments**: {env list}

Files created:
- `{pipeline config path}` — CI/CD pipeline definition
{- `{env config paths}` — environment configurations}
{- `{deploy script path}` — deployment script}
{- `Dockerfile` — container definition (if generated)}

Pipeline stages:
1. Build — compile and bundle
2. Test — unit, integration, E2E
3. Quality — lint, type-check, security
4. Deploy ({env1}) — {auto/manual} promotion
{5. Deploy ({env2}) — manual approval required}

🔲 **Your turn**:
- ✅ "approve" — finalize deployment configuration
- 🔍 "show [file]" — inspect a specific generated file
- 🔧 "edit [file]" — modify a specific configuration
- ➕ "add [component]" — add monitoring, alerts, or additional stages
```

**STOP and wait.**

On "edit": apply requested changes to the specific file, re-present.
On "add": generate the additional component, add to pipeline if applicable.
On "approve" → load `{SKILL_DIR}/actions/finalize.md`.

---

## 7. Audit entry

```
### [{ISO timestamp}] Deploy: Generation

**Phase**: deploy
**Action**: generation
**Artifacts**: {list of generated files}
**Outcome**: Generated {N} deployment files for {platform} targeting {target}. {M} environments configured.
```
