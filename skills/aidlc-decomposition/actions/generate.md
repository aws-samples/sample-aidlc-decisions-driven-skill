# Action: unit-generation

Generate `{SPECS_DIR}/{feature}/units.md` using `{ASSETS_DIR}/units.md` template.

- Read decisions from manifest `decisions.decomposition`. Fall back to `## Decisions Summary` from D2 file.
- Assign every story to exactly one unit
- Define interfaces and dependencies using DDD concepts
- Define Context Map relationships
- **Foundation unit**: For greenfield projects or when architecture requires shared scaffolding (microservices, modular monolith with shared conventions), propose a `foundation` unit as the first unit in the development sequence. This unit covers: repo structure, shared libraries, auth scaffolding, error handling patterns, communication contracts, database setup, and CI/CD base config. It does NOT get user stories assigned — it's infrastructure-only.

**Write** the generated units to `{SPECS_DIR}/{feature}/units.md`.

**Validate**:
- ✅ All stories assigned to exactly one domain unit
- ✅ Clear boundaries and interfaces
- ✅ Dependencies identified with types (Data/API/Event)
- ✅ No circular dependencies
- ✅ Foundation unit (if proposed) is first in development sequence and has no upstream dependencies

**Update Manifest**: Add `decomposition` phase entry: `status: "draft"`, `timestamp`, `files: [units.md]`.

**Present** → **STOP and wait.**

---

# Mode Selection (After Units Approved)

On approval: update manifest, populate `units[]` array for each unit (including foundation if proposed).

## Present Mode Choice

| Mode | Best For |
|------|----------|
| incremental | Teams, greenfield, 3+ units |
| comprehensive | Solo dev, tightly coupled units, ≤3 units |

**STOP and wait.**

- **Incremental** → `state.mode: "incremental"` → present unit dashboard for selection
- **Comprehensive** → `state.mode: "comprehensive"` → auto-continue to `aidlc-design`

## Unit Selection (Incremental Mode)

Present units in development sequence order. The foundation unit (if it exists) should be selected first since other units depend on it.

On selection:
1. `units[{unit}].status` → `"in-progress"`, `.phase` → `"design"`
2. Auto-continue to `aidlc-design`
