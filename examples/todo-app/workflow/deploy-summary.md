# Deployment Summary — todo-app

**Date**: 2026-04-26T12:45:00Z
**CI/CD Platform**: GitHub Actions
**Deployment Target**: Docker / Cloud Run
**Strategy**: Recreate

## Pipeline

| Stage | Trigger | Actions |
|---|---|---|
| Build | Push to main | Install deps, compile TypeScript, run Prisma generate |
| Test | After build | Run Jest (unit + integration), check coverage >= 80% |
| Quality | After test | ESLint, tsc --noEmit |
| Deploy (dev) | Push to main (auto) | Build Docker image, push to registry, deploy to Cloud Run dev |
| Deploy (production) | Manual approval | Promote dev image to production Cloud Run service |

## Environments

| Environment | Branch | Promotion | URL |
|---|---|---|---|
| dev | main | Auto on push | https://todo-app-dev-xxxxx.run.app |
| production | main | Manual approval | https://todo-app-prod-xxxxx.run.app |

## Files Generated

| File | Purpose |
|---|---|
| `.github/workflows/deploy.yml` | CI/CD pipeline definition |
| `Dockerfile` | Multi-stage container build |
| `.env.production.example` | Production environment template |

## Secrets Required

| Secret | Environment | Where to Configure |
|---|---|---|
| `DATABASE_URL` | dev, production | GitHub Secrets |
| `GCP_PROJECT_ID` | dev, production | GitHub Secrets |
| `GCP_SA_KEY` | dev, production | GitHub Secrets |

## Rollback

- **Strategy**: Redeploy previous Cloud Run revision
- **Trigger**: `gcloud run services update-traffic --to-revisions=PREVIOUS=100`
- **Recovery time**: < 30 seconds

## Post-Deployment Checklist

- [ ] Configure secrets in GitHub repository settings
- [ ] Verify GCP Cloud Run service access
- [ ] Set up Cloud SQL PostgreSQL instance
- [ ] Run first deployment to dev
- [ ] Verify health endpoint responds
- [ ] Run smoke test against dev environment
