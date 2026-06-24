# Action: routing

## State Reading Logic

Read `aidlc-manifest.yaml` and extract:

- `state.scope` → workflow scope (`new` / `feature` / `bugfix` / `refactor`)
- `state.sharedPhases` → which shared phases are complete (context, requirements, decomposition, design, tasks, implement, build, deploy)
- `state.mode` → `null` (undecided), `incremental`, or `comprehensive`
- `artifacts` → shared phase artifacts and their status (`draft` / `approved` / `outdated`)
- `units[]` → per-unit state (incremental mode):
  - `status` → `not-started` / `in-progress` / `completed`
  - `phase` → current phase for this unit (design / tasks / implement / completed)
  - `completedPhases` → which phases this unit has finished
  - `implementationMode` → per-unit implementation mode
  - `implementation` → per-unit task counters
  - `artifacts` → per-unit design, tasks artifacts
  - `decisions` → per-unit design, tasks decisions

---

## Routing Logic

Based on manifest state, determine the next skill to dispatch:

### Scope-Aware Phase Skipping

> **Source of truth**: `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md` — read for full scope definitions and phase mappings.

Read `state.scope` from manifest. Apply skip rules from `scopes.md` before routing. Key shortcuts: `bugfix` skips decomposition + deploy; `refactor` skips requirements + decomposition + deploy. When a phase is skipped, treat it as already completed for routing. Do NOT add skipped phases to `state.sharedPhases`.

### Standard Routing Table

| Current State | Next Skill |
|---|---|
| No manifest, no artifacts | `aidlc-context` |
| `context` in `sharedPhases`, no requirements | **Scope check**: if `refactor` → skip to `aidlc-design`. Otherwise → `aidlc-requirements` |
| `requirements` in `sharedPhases`, needs routing | **Scope check**: if `bugfix` → skip decomposition analysis, go straight to `aidlc-design`. Otherwise → Analyze complexity (see below) |
| `decomposition` in `sharedPhases`, mode=`comprehensive` | `aidlc-design` |
| `decomposition` in `sharedPhases`, mode=`incremental` | Unit dashboard (see Incremental Mode Unit Routing) |
| Comprehensive: `design` in `sharedPhases` | `aidlc-tasks` |
| Comprehensive: `tasks` in `sharedPhases` | `aidlc-implement` |
| Comprehensive: `implement` in `sharedPhases`, no `build` | `aidlc-build` |
| Incremental: all units `completed`, no `build` in `sharedPhases` | `aidlc-build` |
| `build` in `sharedPhases`, no `deploy` | **Scope check**: if `bugfix` or `refactor` → present completion message (deploy skipped). Otherwise → `aidlc-deploy` |
| `deploy` in `sharedPhases` | Present completion message |

When the next skill is determined, dispatch it (see Skill Dispatch in SKILL.md).

---

## Post-Requirements Routing

When requirements are complete but no decomposition or design exists, analyze complexity:

**Scope shortcut**: If scope is `bugfix`, skip complexity analysis entirely — go straight to `aidlc-design`. Bugfixes don't decompose.

For `feature` and `new` scopes, read requirements and count:
- Total user stories
- Distinct functional domains/areas
- Distinct user types/personas
- External integrations

**Complex** (5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations):
```
Your project has [X stories] across [Y areas] — recommend decomposition before designing.
```

**Simple** (below all thresholds):
```
Your project is straightforward — going straight to design.
```

Always mention the prototype option:
```
💡 You can also say "prototype" to build a quick throwaway spike first.
```

Present the recommendation, then **STOP and wait**:
```
🔲 **Your turn**:
- ✅ "proceed" — follow recommendation
- 🔀 "go to [design/units]" — override
- 🧪 "prototype" — build a throwaway spike first
```

On user response, dispatch the chosen skill.

---

## Incremental Mode Unit Routing

When mode is `incremental`, present a unit dashboard showing all units and their status. Multiple units can be `in-progress` simultaneously (different sessions/team members).

Present:

```
📍 Unit Dashboard — {feature}

  Active:
  {For each unit with status "in-progress":}
  - 🔄 {name} — {phase} {progress details}

  Available:
  {For each unit with status "not-started":}
  - ⬜ {name} — not started

  Completed:
  {For each unit with status "completed":}
  - ✅ {name} — done

🔲 **Your turn**:
- 🎯 "resume {unit}" — continue working on an active unit
- 🎯 "start {unit}" — begin design for an available unit
- 📋 "show units" — see full unit details
```

**STOP and wait.**

On "resume {unit}": Determine what that unit needs next based on `units[{unit}].phase` and `units[{unit}].completedPhases` (design → tasks → implement). Dispatch the appropriate skill scoped to that unit.

On "start {unit}": Set `units[{unit}].status` to `"in-progress"`, set `units[{unit}].phase` to `"design"`. Dispatch `aidlc-design` scoped to that unit.

**Unit artifact path rule**: When dispatching a skill scoped to a unit, ALL artifacts produced by that skill go into the unit's subdirectory — never into the shared feature directory. Concrete paths:
- Design: `{SPECS_DIR}/{feature}/units/{unit}/design/*.md`
- Tasks: `{SPECS_DIR}/{feature}/units/{unit}/tasks.md`
- Decisions: `{WORKFLOW_DIR}/{feature}/units/{unit}/decisions-*.md`
- Audit: `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md`

Example for feature `my-feature`, unit `auth`:
- ✅ Correct: `.aidlc/specs/my-feature/units/auth/design/components.md`
- ❌ Wrong: `.aidlc/specs/my-feature/design/auth-design.md`

If all units are `completed` → present completion message.

---

## Solutions Review (Incremental Mode)

When 2+ units have design artifacts with status `approved`, recommend a solutions review before implementation begins.

Present:

```
📍 Solutions Review Recommended

[X] units have completed design. Before implementing, review designs for cross-unit conflicts.
(Checks for: conflicting API patterns, incompatible data models, inconsistent error handling, overlapping responsibilities)

🔲 **Your turn**:
- ✅ "review" — run the cross-unit design review
- ⏭️ "skip" — proceed to implementation without review
```

**STOP and wait.**

The user can also request a review at any time by saying "run review", "review designs", or "solutions review". If only one unit has completed design, skip — there's nothing to cross-check.

On "review" / "yes" / "run review": dispatch `aidlc-solutions-review` — read `{PLATFORM_DIR}/skills/aidlc-solutions-review/SKILL.md` and follow its instructions.

On "skip": proceed to the next unit's design or tasks phase.
