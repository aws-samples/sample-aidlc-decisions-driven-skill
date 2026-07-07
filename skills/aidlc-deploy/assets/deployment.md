# Deployment Template

**Path**: `{SPECS_DIR}/{feature}/deployment.md`
**Use when**: Always — this is the deployment specification and source of truth for how the application is deployed.

```markdown
# Deployment: [Feature Name]

## Summary
<!-- 10-line max digest. Generate step reads ONLY this section + Files to Generate for execution. -->
- **CI/CD**: [Platform] — [trigger summary]
- **Target**: [Deployment target] — [1-sentence description]
- **Strategy**: [Deployment strategy]
- **Environments**: [List] — [promotion approach]
- **IaC**: [Tool or "None"]
- **Secrets**: [Management approach]
- **Rollback**: [Strategy]
- **Verification**: [Post-deploy check method]

---

## Pipeline Architecture

### Stages

| # | Stage | Trigger | Purpose | Key Actions |
|---|---|---|---|---|
| 1 | [stage] | [trigger] | [purpose] | [actions] |

### Flow Diagram

```
[text-based flow diagram showing stage progression and branching]
```

---

## Target Infrastructure

### Topology

| Component | Service/Resource | Environment | Configuration |
|---|---|---|---|
| [component] | [service] | [envs] | [key config] |

### Environment Layout

| Environment | Purpose | Trigger | Auto-deploy | Protection |
|---|---|---|---|---|
| [env] | [purpose] | [trigger] | [yes/no] | [rules] |

---

## Promotion Flow

```
[text diagram showing how code moves between environments]
```

- **[env]**: [promotion description]

---

## Security & Secrets

### Secrets Required

| Secret | Purpose | Environments | Storage |
|---|---|---|---|
| [SECRET_NAME] | [what it's for] | [which envs] | [storage method] |

### Network & Access

- [network isolation approach]
- [access control for deployment]
- [secret injection method]

---

## Operations Integration

### Health & Readiness

| Check | Endpoint/Method | Timeout | Failure Action |
|---|---|---|---|
| [check] | [endpoint] | [timeout] | [action] |

### Observability

- **Logging**: [approach]
- **Metrics**: [approach]
- **Alerting**: [approach]

### Graceful Shutdown

- Signal: [signal]
- Grace period: [seconds]
- Drain: [connection drain approach]

---

## Rollback Strategy

- **Method**: [rollback method]
- **Trigger**: [what initiates rollback]
- **Steps**:
  1. [ordered rollback actions]
- **Recovery time**: [estimated]
- **Data considerations**: [migration rollback approach if applicable]

---

## Database Migrations

<!-- Omit this section entirely if no database -->
- **Strategy**: [migration approach]
- **Timing**: [when migrations run relative to deploy]
- **Command**: [migration command]
- **Failure handling**: [what happens if migration fails]
- **Rollback**: [how to reverse a migration]

---

## Files to Generate

<!-- This section is the contract for the generate step — list every file that will be produced -->

| File | Purpose | Notes |
|---|---|---|
| [path] | [description] | [considerations] |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| [risk] | Low/Med/High | Low/Med/High | [mitigation] |

---

## Cost Estimate

| Resource | Environment | Estimated Monthly | Notes |
|---|---|---|---|
| [resource] | [env] | [cost] | [assumptions] |

**Total estimated**: [range] /month

*Note: Estimates based on [pricing region]. Actual costs depend on traffic and usage.*
```

## Template Rules

1. **Summary section** is mandatory — downstream steps read it as a quick reference
2. **Files to Generate** is the contract between plan and generate — every file listed here MUST be produced during generation
3. **Database Migrations** section: omit entirely if no database in the design
4. **Operations Integration**: if `design/operations.md` doesn't exist, use sensible defaults and note "operations design not specified"
5. **Cost Estimate**: provide rough ranges; mark as estimates. Omit for "None" IaC + simple PaaS targets where costs are obvious
6. **Risk Assessment**: focus on deployment-specific risks, not application-level risks
7. **Adaptation**: collapse or omit low-value sections for simple projects (solo dev, single service, no IaC). Never omit Summary, Pipeline, Target Infrastructure, or Files to Generate.
