# Action: tasks-generation

## Scope Check

Read `state.scope` from manifest:

| Scope | Behavior |
|---|---|
| `new`/`feature` | Full generation — all derivation, waves, parallel |
| `bugfix` | Streamlined — standard mode, single wave, add mandatory regression task, skip testing strategy derivation. Focus: reproduce→fix→verify→regression |
| `refactor` | Focused — add mandatory baseline+verify tasks, standard mode, skip new test setup. Focus: baseline→restructure→verify→cleanup |

---

## Step 0: Resolve Paths

```
IF incremental: TASKS_OUT={SPECS}/{feature}/units/{unit}/tasks.md, DESIGN_IN=units/{unit}/design/*
ELSE: TASKS_OUT={SPECS}/{feature}/tasks.md, DESIGN_IN={SPECS}/{feature}/design/*
```

## Derive Tasks

Source → Task type:
- Components → implementation tasks
- Entities → schema/migration tasks
- Endpoints → API route tasks
- Integrations → integration tasks
- NFRs → infrastructure/performance tasks
- Correctness properties → PBT tasks
- Testing strategy → test setup + scenario tasks
- Operations → logging, health, metrics, shutdown, config tasks

### Operations Derivation (skip for bugfix/refactor)

If `design/operations.md` exists:

| Source | Task |
|---|---|
| Logging | Logger setup (library, config, request-id middleware) |
| Health & Readiness | Health endpoints (liveness + readiness checks) |
| Graceful Shutdown | Shutdown handler (signals, drain, timeout) |
| Config Management | Config validation (env schema, startup checks) |
| Metrics (Standard+) | Metrics instrumentation (middleware, /metrics) |
| Error Tracking (Dedicated) | Error tracking integration (SDK, source maps) |
| Alerting (Full) | Alerting config (rules, thresholds, channels) |

**Placement**: logger+config→Phase 1; health+shutdown→with routes; metrics→after features; tracking+alerting→polish phase.
**Sizing**: sub-tasks (0.5-1 day). Group into 1-2 tasks unless Full level.

### Testing Derivation

| Source | Task |
|---|---|
| Unit framework (D3) | Framework setup (if non-trivial) |
| Integration approach (D3) | Integration setup (test DB, containers) |
| E2E framework (D3) | E2E setup + scenario tasks per critical flow |
| Load tool (D3) | Load test setup + scenarios |
| PBT (D3+correctness.md) | PBT tasks per property |
| API tool (D3) | API test collection task |
| testing-strategy.md coverage | Ensures all components/endpoints have test coverage |

### TDD-Aware Ordering

- **TDD**: test skeleton precedes each impl task. Pattern: write test→implement→verify.
- **Outside-In**: E2E first (failing)→integration→unit. Impl fills layers.
- **Test-After** (default): impl first, tests follow in same phase or dedicated phase.

Read D4 from manifest `decisions.tasks`. Read `{ASSETS}/tasks.md` for output structure.

**Format**: Kiro checkboxes — Phase=`- [ ] 1. Name`, Task=`  - [ ] 1.1 Title`, Details=plain items.

Write to `{TASKS_OUT}`.

## Execution Waves (MANDATORY)

1. Build phase-level dependency graph
2. Phases with no unresolved deps → next wave
3. Tasks within phase execute sequentially
4. Parallel waves: assign file ownership per phase — no overlap
5. Overlap detected → move conflicting phase to next wave

## Validate

**Coverage**: all components→tasks, all US-*→tasks, all endpoints→test tasks
**Format**: Kiro checkboxes, waves with file ownership, no overlap
**Deps**: no circular, no missing
**Testing**: D3-backed only (no assumed frameworks), E2E if selected, load if selected, TDD ordering if D4=TDD
**Operations** (if operations.md exists): logger Phase 1, health exists, shutdown exists, config exists; metrics if Standard+; tracking if Dedicated
**Traceability**: run gap detection (below)

## Traceability Gap Detection

Run BEFORE presenting:

**Forward (requirements→tasks)**:
1. Collect all `US-*` from requirements.md
2. Every US-* must appear in requirements_coverage with ≥1 task
3. Missing → fail, add task or document exclusion

**Forward (design→tasks)**:
1. Collect components/endpoints/entities from design Traceability
2. Every element must map to ≥1 task in design_coverage
3. Missing → fail, add task

**Reverse (tasks→upstream)**:
- Every task must have `**Ref**:` to design section. Unanchored → flag `⚠️`

**Testing cross-ref** (if testing-strategy.md exists): coverage mapping matches, directory structure aligns.

**FAIL if** any US-* or design component has zero coverage without justification.

## Update Manifest

Incremental: `units[{unit}].artifacts.tasks` → `status:"draft"`, `totalTasks`
Comprehensive: `artifacts.tasks` → `status:"draft"`

## Present Results

```
📍 Tasks

- **Total Tasks**: [X] across [Y] phases
- **Execution Waves**: [Z] waves ([W] parallel)
- **Coverage**: [A] components, [B] entities, [C] endpoints
- **Testing**: [U] unit, [I] integration, [E] E2E, [L] load, [P] PBT tasks
- **Strategy**: [from D4]

Artifact at `{SPECS}/{feature}/tasks.md`.

---
🔲 **Your turn**:
- ✅ "approve" — finalize tasks
- ✏️ "change [what]" — request edits
- ← "back to design" — return to design phase
```

**STOP and wait.**

On approval: manifest status→"approved", add to sharedPhases/completedPhases. Audit.

**Handoff**:
- Comprehensive: auto-continue to implement.
- Incremental: return to Unit Dashboard:
  ```
  ✅ {unit} tasks approved.

  🔲 **Your turn**:
  - ▶️ "implement" — start implementation for {unit}
  - 🎯 "start {other-unit}" — design another unit
  - 📋 "show units" — unit dashboard
  ```
  **STOP and wait.**
