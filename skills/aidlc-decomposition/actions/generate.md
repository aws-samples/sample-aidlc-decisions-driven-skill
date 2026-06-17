# Action: unit-generation

Generate `{SPECS_DIR}/{feature}/units.md` using `{ASSETS_DIR}/units.md` template.

- Read decisions from manifest `decisions.decomposition`. Fall back to `## Decisions Summary` from D2 file.
- Assign every story to exactly one unit
- Define interfaces and dependencies using DDD concepts
- Define Context Map relationships

**Write** the generated units to `{SPECS_DIR}/{feature}/units.md`.

**Validate**:
- ✅ All stories assigned to exactly one unit
- ✅ Clear boundaries and interfaces
- ✅ Dependencies identified with types (Data/API/Event)
- ✅ No circular dependencies
- ✅ Infrastructure units with `Source: foundation` preserved from previous runs

**Update Manifest**: Add `decomposition` phase entry: `status: "draft"`, `timestamp`, `files: [units.md]`.

**Present** → **STOP and wait.**

---

# Mode Selection (After Units Approved)

On approval: update manifest, populate `units[]` array for each unit.

## Determine Recommendation

- **Brownfield**: recommend skipping foundation (conventions already exist)
- **Greenfield**: recommend foundation (important for alignment)

## Present Mode Choice

| Mode | Best For |
|------|----------|
| incremental | Teams, greenfield, 3+ units |
| incremental (skip foundation) | Brownfield with established patterns |
| comprehensive | Solo dev, tightly coupled units, ≤3 units |

**STOP and wait.**

- **Incremental** → `state.mode: "incremental"` → auto-continue to `aidlc-foundation`
- **Skip foundation** → `state.mode: "incremental"`, `state.foundationSkipped: true` → unit selection below
- **Comprehensive** → `state.mode: "comprehensive"` → auto-continue to `aidlc-design`

## Unit Selection (Skip Foundation only)

Present domain units for selection. On selection:
1. `units[{unit}].status` → `"in-progress"`, `.phase` → `"design"`
2. Auto-continue to `aidlc-design`
