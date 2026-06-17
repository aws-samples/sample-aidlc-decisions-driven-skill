# Action: foundation-generation

Generate `{SPECS_DIR}/{feature}/foundation.md` using `{ASSETS_DIR}/foundation-core.md` template. If team size > 1, also load `{ASSETS_DIR}/foundation-team.md`.

## Generation Rules

- Read decisions from manifest `decisions.foundation`. Fall back to `## Decisions Summary` from DF file.
- Adapt content based on team size (skip Team Assignments, Sync Schedule, Risks for solo)
- **Use primary language/runtime to make content concrete**:
  - Repository structure: language-idiomatic layout
  - Package manager and scripts: chosen package manager
  - Linting/formatting: language-standard tools
  - Testing: language-standard test runner
  - Shared types/contracts: language-native syntax
  - Monorepo tooling: match chosen package manager
- **Honor "Shared Foundations Level" from DF**:
  - **Minimal**: Conventions + Error Handling only
  - **Standard**: + Auth + Inter-Unit Communication + Database Strategy
  - **Comprehensive**: ALL sections including API Architecture, Integration Contracts, Infrastructure, Logging, CI/CD

**Write** the generated foundation to `{SPECS_DIR}/{feature}/foundation.md`.

## Infrastructure Unit Management

1. Generate `foundation.md`
2. Read current `units.md`
3. Based on infrastructure unit strategy from DF:

**Combined** (single Foundation unit):
- Add "Foundation" unit: scaffold, shared packages, auth, error handling, DB, dev tooling, CI/CD
- Dependencies: none (all others depend on this)

**Separate** (individual infra units):
- Add "Foundation" + separate units per infra component
- Mark infra units depending on Foundation
- Mark domain units depending on relevant infra units

4. Update Development Sequence — infrastructure units go in Phase 1

## Validate

- ✅ Repository structure, auth, error format, communication, DB, shared types all defined
- ✅ Integration contracts sketched for all unit pairs
- ✅ Infrastructure units added to units.md
- ✅ No circular dependencies

## Update Steering

**`{STEERING_DIR}/tech.md`**: Add Shared Conventions section. Preserve existing content.
**`{STEERING_DIR}/structure.md`**: Add Repository Structure section. Merge, don't overwrite.

## Update Manifest

Add `foundation` phase entry. Update `decomposition` timestamp. Update `steering.updatedBy.tech` and `.structure`.

## Present

```
📍 Foundation Specification

- **Team**: [Solo / Small team / Multiple teams]
- **Repo**: [strategy]
- **Auth**: [approach]
- **Comms**: [pattern]
- **DB**: [strategy]
- **Infrastructure Units**: [list added]

---
🔲 **Your turn**:
- ✅ "approve" — approve foundation and select first unit
- ✏️ "change [what]" — request edits
```

**STOP and wait.**

---

# Unit Selection (After Foundation Approved)

On approval: update manifest (`artifacts.foundation.status` → `"approved"`, add to `state.sharedPhases`). Append audit.

Present the unit selection prompt:

```
📍 Foundation Approved — Select First Unit

Ready to design and implement units one at a time.

**Infrastructure units** (recommended first):
1. 🏗️ [Foundation] — project scaffold, shared packages, dev tooling
[2. 🏗️ [Gateway/other infra] — [purpose] (if separate infra units)]

**Domain units**:
[N.] 📦 [Unit A] — [purpose] ([X] stories)
[N+1.] 📦 [Unit B] — [purpose] ([Y] stories)

💡 Infrastructure units should be completed before domain units.

---
🔲 **Your turn**:
- 🎯 "select [unit name]" — start working on that unit
- 📋 "show units" — see full unit details
```

**STOP and wait.**

When user selects a unit:
1. Update manifest: `units[{unit}].status` → `"in-progress"`, `units[{unit}].phase` → `"design"`
2. Auto-continue to `aidlc-design`

When returning after completing a unit:
- ALL completed → present completion summary, recommend code-review
- Otherwise → present unit dashboard (active, available, completed units) with same infrastructure-first ordering
