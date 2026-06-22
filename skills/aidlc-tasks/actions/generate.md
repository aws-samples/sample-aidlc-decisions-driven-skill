# Action: tasks-generation

## Scope Check

Read `state.scope` from manifest. Adjust task generation behavior based on scope:

| Scope | Task Generation Behavior |
|---|---|
| `new` / `feature` | Full task generation — all derivation rules, execution waves, parallel support |
| `bugfix` | Streamlined — fewer tasks, standard mode only recommended, include mandatory regression test task |
| `refactor` | Focused — include mandatory "verify no behavior change" task, emphasize test-before-change pattern |

### Bugfix Scope Adjustments

When scope is `bugfix`:
- **Recommend standard mode only** in select-mode (parallel/autonomous overkill for 3–8 tasks)
- **Add mandatory task**: "Verify regression — confirm existing tests pass before AND after fix"
- **Simplify execution waves**: likely single wave (no parallelism needed)
- **Skip** testing strategy derivation from D3 (bugfix uses existing test infrastructure)
- **Focus** tasks on: reproduce → fix → verify → regression check

### Refactor Scope Adjustments

When scope is `refactor`:
- **Add mandatory first task**: "Capture baseline — run full test suite, record passing state"
- **Add mandatory last task**: "Verify no behavior change — same tests pass, same API contracts hold"
- **Recommend standard mode** (changes are interconnected, parallel risks conflicts)
- **Skip** new test framework setup tasks (use existing infrastructure)
- **Focus** tasks on: baseline → restructure → verify → cleanup

---

## Step 0: Resolve Output Paths

```
IF incremental mode (unit is set):
  TASKS_OUT = {SPECS_DIR}/{feature}/units/{unit}/tasks.md
  DESIGN_IN = {SPECS_DIR}/{feature}/units/{unit}/design/*
ELSE:
  TASKS_OUT = {SPECS_DIR}/{feature}/tasks.md
  DESIGN_IN = {SPECS_DIR}/{feature}/design/*
```

## Derive Tasks

Derive from design documents:
- **Components** → implementation tasks
- **Entities** → schema/migration tasks
- **Endpoints** → API route tasks
- **Integrations** → integration tasks
- **NFRs** → infrastructure/performance tasks
- **Correctness properties** → PBT tasks
- **Testing strategy** → test setup, framework configuration, and test scenario tasks

### Testing Task Derivation (from D3/D4 + design/testing-strategy.md or testing section)

| D3/Design Source | Derived Task(s) |
|---|---|
| Unit test framework (D3) | Test framework setup/config task (if not trivial) |
| Integration test approach (D3) | Integration test setup task (test DB, containers, etc.) |
| E2E framework (D3) | E2E setup task + scenario tasks per critical user flow |
| Load testing tool (D3) | Load test setup + scenario task(s) |
| PBT framework (D3 + correctness.md) | PBT implementation tasks per property |
| API testing tool (D3) | API test collection/automation task |
| testing-strategy.md coverage mapping | Ensures every component/endpoint has test task coverage |

### TDD-Aware Ordering

If D4 answer = TDD:
- For each implementation task, generate a paired test skeleton task that **precedes** it in the same phase
- Pattern: `Write test for [component]` → `Implement [component]` → `Verify tests pass`
- Test skeleton tasks are sized as sub-tasks (not full 1-2 day tasks)

If D4 answer = Outside-In:
- E2E skeleton tasks come first (failing), then integration, then unit
- Implementation tasks fill in layers to make outer tests pass

If D4 answer = Test-After (default):
- Implementation tasks come first, testing tasks follow within the same phase or as a dedicated testing phase

Read decisions from manifest `decisions.tasks`. Fall back to `## Decisions Summary` from decisions file.
Read `{ASSETS_DIR}/tasks.md` for output structure.

Use **Kiro-compatible checkbox format**:
- Phase = top-level: `- [ ] 1. Phase Name`
- Task = nested: `  - [ ] 1.1 Task Title`
- Details = plain list items (no checkbox)

**Write** the generated tasks to `{TASKS_OUT}`.

## Execution Waves (MANDATORY)

Group phases into waves based on inter-phase dependencies:

1. Build dependency graph at phase level
2. Phases with no unresolved dependencies form the next wave
3. Tasks within each phase execute sequentially
4. For parallel waves (2+ phases), assign file ownership per phase
5. File ownership must not overlap between phases in the same wave
6. If overlap → move one phase to next wave

## Validate Output

- ✅ All design components have tasks
- ✅ All user stories covered
- ✅ Dependencies correct (no circular, no missing)
- ✅ Kiro checkbox format correct
- ✅ Execution Waves present with file ownership
- ✅ No file ownership overlap in parallel waves
- ✅ Every component has associated unit test task(s)
- ✅ Every endpoint has integration test coverage task
- ✅ If E2E framework selected in D3, E2E tasks exist for critical user flows
- ✅ If load testing selected in D3, load test task(s) exist
- ✅ If TDD selected in D4, test tasks precede implementation tasks in ordering
- ✅ Testing tasks derive from D3 testing choices — no test frameworks assumed without D3 backing
- ✅ **Traceability complete** (see Traceability Gap Detection below)

## Traceability Gap Detection

After generating tasks.md, run this check BEFORE presenting results:

### Requirements → Tasks (forward trace)
1. Read `requirements.md` — collect every `US-*` ID
2. Check the `requirements_coverage` section in tasks.md — every US-* must appear with at least one implementing task
3. If a US-* has no task → **fail** — add the missing task or document why it's excluded

### Design → Tasks (forward trace)
1. Read design `Traceability` section — collect all components, endpoints, and entities
2. Check the `design_coverage` section in tasks.md — every design element must map to at least one task
3. If a component/endpoint/entity has no task → **fail** — add the missing task

### Reverse trace (tasks → upstream)
1. For every task phase in tasks.md, verify it references a design file and section via `**Ref**:`
2. Tasks without a `**Ref**` to a design element are unanchored — flag as `⚠️ No design reference`

### Gap report
If gaps are found, fix them before presenting. If intentional (deferred to another unit, infrastructure-only), document in the coverage section:
```
| US-X | — | ⚠️ Deferred to unit: payments |
```

**Fail condition**: Do NOT present results if any US-* or design component has zero task coverage without documented justification.

## File Ownership Overlap Validation

For each parallel wave, verify no overlapping paths between phases. If overlap detected: move conflicting phase to next wave, report the conflict.

## Testing-Design Cross-Reference Validation

If `design/testing-strategy.md` (or testing section in compact design) exists:
- Verify `testing_coverage` section in tasks maps back to the coverage mapping in testing-strategy.md
- Every component listed in testing-strategy.md coverage mapping has corresponding test task(s)
- Every endpoint listed in testing-strategy.md coverage mapping has corresponding integration test task
- Test directory structure referenced in tasks aligns with testing-strategy.md `test_architecture.directory_structure`

## Update Manifest

- **Incremental**: `units[{unit}].artifacts.tasks` → `status: "draft"`, update `totalTasks`
- **Comprehensive**: `artifacts.tasks` → `status: "draft"`

## Present Results

```
📍 Tasks

- **Total Tasks**: [X] across [Y] phases
- **Execution Waves**: [Z] waves ([W] parallel)
- **Coverage**: [A] components, [B] entities, [C] endpoints
- **Testing**: [U] unit, [I] integration, [E] E2E, [L] load, [P] PBT tasks
- **Strategy**: [from D4]
- **Testing Approach**: [TDD / Test-After / Outside-In from D4]

Artifact at `{SPECS_DIR}/{feature}/tasks.md`.

---
🔲 **Your turn**:
- ✅ "approve" — finalize tasks
- ✏️ "change [what]" — request edits
- ← "back to design" — return to design phase
```

**STOP and wait.**

On approval: update manifest (status → "approved", add to sharedPhases/completedPhases). Append audit. Auto-continue to implement.
