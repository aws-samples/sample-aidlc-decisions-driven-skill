# Action: Finalize Deployment

> **Precondition**: Run only after the user approved the generated files ("approve" at generate.md step 8). This action marks the whole workflow complete with no further stops. If you arrive here without that approval (e.g., after context recovery), go back to `actions/generate.md` step 8 and re-present instead.

## 1. Generate deploy-summary.md

Write to `{WORKFLOW_DIR}/{feature}/deploy-summary.md`:

```markdown
# Deployment Summary — {feature}

**Date**: {ISO timestamp}
**CI/CD Platform**: {platform}
**Deployment Target**: {target}
**Strategy**: {strategy}

## Pipeline

| Stage | Trigger | Actions |
|---|---|---|
| Build | {trigger} | {actions} |
| Test | After build | {test suites} |
| Quality | After test | {quality checks} |
| Deploy ({env}) | {trigger/approval} | {deploy actions} |

## Environments

| Environment | Branch | Promotion | URL |
|---|---|---|---|
| {env} | {branch} | {auto/manual} | {placeholder or TBD} |

## Files Generated

| File | Purpose |
|---|---|
| `{path}` | {description} |

## Secrets Required

| Secret | Environment | Where to Configure |
|---|---|---|
| `{SECRET_NAME}` | {env} | {CI platform secrets UI} |

## Rollback

- **Strategy**: {rollback approach}
- **Trigger**: {how to initiate rollback}
- **Recovery time**: {expected}

## Post-Deployment Checklist

- [ ] Configure secrets in {CI platform}
- [ ] Verify deployment target access/credentials
- [ ] Set up monitoring/alerting (if not automated)
- [ ] Run first deployment to {lowest env}
- [ ] Verify health checks respond
- [ ] Document runbook for on-call (if applicable)
```

---

## 2. Update manifest

```yaml
artifacts.deploy:
  status: "approved"
  timestamp: "{ISO timestamp}"
  files: [deployment.md, deploy-summary.md]

state.sharedPhases: [...existing, "deploy"]
state.status: "completed"
```

---

## 3. Present completion

```
📍 AI-DLC Workflow Complete — {feature}

All phases finished:
- ✅ Inception: Context → Requirements → Decomposition → Foundation
- ✅ Construction: Design → Tasks → Implement
- ✅ Operation: Build and Test → Deploy

**Deployment spec**: `{SPECS_DIR}/{feature}/deployment.md`
**Deployment summary**: `{WORKFLOW_DIR}/{feature}/deploy-summary.md`

Next steps (manual):
1. Configure secrets in your CI/CD platform
2. Push to trigger your first pipeline run
3. Verify deployment in {lowest environment}

{If solutions-review or code-review not run:}
💡 Optional: Run `review` for a code quality check before your first deploy.
```

---

## 4. Audit entry

```
### [{ISO timestamp}] Deploy: Complete

**Phase**: deploy
**Action**: deploy-complete
**Artifacts**: deploy-summary.md, {list of pipeline/config files}
**Outcome**: Deployment configuration finalized. Workflow complete. {N} environments configured, {M} secrets required.
```

---

## 5. Final audit summary

Append to `{WORKFLOW_DIR}/{feature}/audit.md`:

```
### [{ISO timestamp}] Workflow Complete

**Feature**: {feature}
**Duration**: {created} → {now}
**Phases completed**: {list all from state.sharedPhases}
**Mode**: {incremental/comprehensive}
**Units**: {N completed} (incremental only)
**Final status**: All phases complete. Deployment configured for {target} via {CI platform}.
```
