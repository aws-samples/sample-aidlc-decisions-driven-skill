# Deployment Strategies Reference

## Strategy Comparison

| Strategy | Downtime | Rollback Speed | Resource Cost | Complexity | Best For |
|---|---|---|---|---|---|
| Recreate | Yes (brief) | Redeploy | 1x | Low | Dev environments, batch jobs |
| Rolling | No | Gradual | 1x-1.5x | Medium | APIs, microservices |
| Blue-Green | No | Instant | 2x | Medium | Critical services, databases |
| Canary | No | Instant (halt) | 1x + small % | High | High-traffic, risk-sensitive |
| Feature Flags | No | Instant (toggle) | 1x | Medium | Gradual feature rollout |

## Recreate

Stop old version entirely, then start new version.

**When to use**: Dev/test environments, offline jobs, acceptable downtime windows.
**Pipeline steps**: Stop → Deploy → Health check → Route traffic
**Rollback**: Redeploy previous version (minutes)

## Rolling

Replace instances one at a time (or in batches).

**When to use**: Stateless services, APIs, microservices.
**Pipeline steps**: Deploy batch → Health check batch → Next batch → Repeat
**Rollback**: Halt rollout + redeploy previous (minutes)
**Config**: `maxSurge`, `maxUnavailable` (Kubernetes), batch size

## Blue-Green

Run two identical environments; switch traffic atomically.

**When to use**: Critical services needing instant rollback, database migrations.
**Pipeline steps**: Deploy to inactive → Verify → Switch traffic → Decommission old
**Rollback**: Switch traffic back to previous (seconds)
**Trade-off**: Double infrastructure cost during deployment window

## Canary

Route a small percentage of traffic to new version, gradually increase.

**When to use**: High-traffic services, risk-sensitive changes, A/B testing deploys.
**Pipeline steps**: Deploy canary (5%) → Monitor metrics → Increase (25%, 50%, 100%) → Promote
**Rollback**: Route all traffic back to stable (seconds)
**Metrics to watch**: Error rate, latency p95/p99, business metrics

## Feature Flags

Deploy code to all instances but toggle features independently.

**When to use**: Gradual feature rollout, A/B testing, kill switches.
**Pipeline steps**: Deploy (feature off) → Enable for internal → Enable for % → Enable for all
**Rollback**: Toggle flag off (instant, no redeploy)
**Tools**: LaunchDarkly, Unleash, AWS AppConfig, custom flags

---

## Environment Patterns

### Minimal (solo/small team)
```
main → production
```

### Standard (small/medium team)
```
feature branch → dev (auto)
main → staging (auto) → production (manual approval)
```

### Enterprise (medium/large team)
```
feature branch → dev (auto)
develop → integration (auto)
release/* → staging (auto) → production (manual + change ticket)
hotfix/* → production (expedited approval)
```

---

## Health Checks

Every deployment should verify health before routing traffic:

| Check | When | Timeout | Action on Fail |
|---|---|---|---|
| Startup probe | Container start | 30-120s | Restart container |
| Readiness probe | Before routing traffic | 5-10s | Don't route traffic |
| Liveness probe | Ongoing | 5-10s | Restart container |
| Smoke test | Post-deploy | 60s | Trigger rollback |

### Smoke Test Checklist
- Health endpoint returns 200
- Database connection succeeds
- External service dependencies reachable
- Critical user journey works (login, core action)

---

## Secrets Management Patterns

| Platform | Service | Access Pattern |
|---|---|---|
| GitHub | GitHub Secrets | `${{ secrets.NAME }}` |
| GitLab | CI/CD Variables | `$VARIABLE_NAME` (masked, protected) |
| AWS | Secrets Manager / SSM | SDK call at runtime or buildspec env |
| Azure | Key Vault | Pipeline variable group linked to vault |
| GCP | Secret Manager | `gcloud secrets versions access` |
| Generic | HashiCorp Vault | API call or agent injection |

### Rules
- Never commit secrets to source control
- Rotate secrets on schedule (90 days recommended)
- Use different secrets per environment
- Audit secret access
- Use short-lived tokens where possible (OIDC, STS)
