# Action: design-generation

## Step 0: Resolve Output Paths

```
IF incremental (unit set):
  DESIGN_OUT = {SPECS}/{feature}/units/{unit}/
  DETAIL_OUT = {SPECS}/{feature}/units/{unit}/design/
ELSE:
  DESIGN_OUT = {SPECS}/{feature}/
  DETAIL_OUT = {SPECS}/{feature}/design/
```

Create directories if needed. All writes use these paths — no exceptions.

## Step 0.5: Version Resolution

Resolve current stable version for each D3-chosen technology via web search / package registry:
- npm→Node/TS, PyPI→Python, Maven→Java, crates.io→Rust, pkg.go.dev→Go, official pages→runtimes/DBs
- Record as version map: `{tool}: {major.minor.patch}`
- Use in ALL design docs (implementation.md, components.md, etc.)

**Priority**: runtime → framework → ORM → database → test runner → IaC → build tool

**Rules**:
- Only D3-chosen tools — no extras. Prefer LTS over bleeding-edge.
- If major version <3 months old with limited ecosystem → prefer previous stable.
- Fallback (no web): use training knowledge, mark `⚠️ unverified`.
- Store in manifest `versions` section.

---

## Format Selection

- **Simple** (≤10 stories AND single domain): compact `design.md` using `{ASSETS}/design-compact.md`
- **Complex** (11+ stories OR multiple domains): modular `design.md` + `design/` folder

## External Resources

If `{STEERING}/resources.md` lists resources (not "none"):
- Design tool MCP → components.md. API specs → api-spec.md basis. Design docs → align patterns.
- Package registries for version resolution (npm, PyPI, Maven, etc.)
- Cite external sources.

## Writing Strategy

1. Read all needed templates + inputs in one call
2. Write parallel batches:
   - Batch 1: `components.md`, `data-model.md`, `api-spec.md`
   - Batch 2: `integration.md`, `implementation.md`
   - Conditional: `operations.md` (if observability≠None, scope≠bugfix/refactor), `testing-strategy.md` (if testing choices, not prototype), `correctness.md` (if PBT), `nfr.md` (if NFR answered)
3. Checkpoint: after each write, update manifest `artifacts.design.files` + set `status:"partial"`
4. Write `design.md` last (slim: Summary + Architecture + Traceability + References)
5. Update manifest status `"partial"` → `"draft"`

## No-Assumptions Rule

**⛔ ONLY D3 choices.** Read from manifest `decisions.design` (fallback: Decisions Summary section). Use `[TBD - not decided in D3]` for missing. Never assume unchosen tech.

## Parity Rule (rewrite scope only)

**⛔ The baseline is the spec.** D3 chooses the technology; the parity inventories choose the content.

- **Data model is a derivation, not a design**: read `.aidlc/reverse-engineer/parity/entities.md`. data-model.md opens with an explicit **type-mapping table** (legacy type → modern type, e.g., DDS `PACKED(7,2)` → `DECIMAL(7,2)`, `CHAR(1)` flag → `BOOLEAN` with a recorded mapping). Every legacy field maps to a modern field (same table) or cites an approved `DEV-*` from deviations.md. Renames/merges/normalization are fine — but each is a mapping row, never an omission. Per-entity modern field count must reconcile: legacy count − DROPPED + NEW = modern count.
- **Screens**: every `SCR-*` in `parity/screens.md` maps to a component/page/route in components.md (per the D1 UX-parity answer), or cites a `DEV-*`. Function keys map to actions.
- **Operations**: every `OP-*` maps to an endpoint in api-spec.md or a `DEV-*`.
- **No invention**: entities, fields, or endpoints with no baseline origin and no `DEV-*` entry are a FAIL — additions require a `[NEW]` deviation first.

## Load Guides

| Guide | Load When |
|---|---|
| `architecture-patterns.md` | ALWAYS |
| `api-design.md` | API choices in D3 |
| `frontend-architecture.md` | Frontend framework in D3 |
| `mobile-architecture.md` | Mobile platform in D3 |
| `distributed-patterns.md` | Microservices/distributed |
| `property-based-testing.md` | PBT=Yes |
| `observability-patterns.md` | Observability≠None (stack-specific section only) |

Skip non-matching. Stack-aware: read only language-relevant sections within loaded guides.

**Testing strategy**: generate if D3 has testing choices AND not prototype. Use `{ASSETS}/design-testing-strategy.md`, cross-ref components + api-spec for coverage mapping.

## Templates

Simple: `design-compact.md` only.
Complex: `design.md` + `design-components.md` + `design-data-model.md` + `design-api-spec.md` + `design-integration.md` + `design-implementation.md` + conditionals: `design-operations.md`, `design-testing-strategy.md`, `design-correctness.md`, `nfr.md`

**Operations rules**:
- Simple format: embed `## Operations` in compact file (no separate file)
- Complex format: separate `design/operations.md`
- Sections by level: Minimal=logging+health+shutdown+config, Standard=+metrics+errors, Full=+alerting
- Read `observability-patterns.md` (stack section only)

## Validate

**Coverage**: all components/entities/endpoints/integrations designed
**D3 compliance**: all choices used, no assumptions, `[TBD]` for missing
**Cross-refs**: files reference each other correctly
**Testing**: strategy covers D3 choices; directory structure consistent with implementation.md
**Operations** (if generated): logging table covers all components; readiness covers all deps; health paths no conflict with API; config vars include all secrets from implementation.md
**Versions**: all pinned (no "latest"), no EOL/deprecated
**Traceability**: run gap detection (below)
**Parity (rewrite scope) — FAIL conditions, fix before presenting**:
- FAIL if any entity's field reconciliation doesn't balance (legacy − DROPPED + NEW ≠ modern) — recount mechanically (script over the generated schema), don't eyeball
- FAIL if any SCR-* or OP-* is unmapped and has no DEV-* entry
- FAIL if data-model.md lacks the type-mapping table or any field row lacks a legacy origin / DEV-* citation

## Traceability Gap Detection

Run BEFORE presenting:
1. Collect all `US-*` from requirements.md
2. Check design.md Traceability — each US-* must map to ≥1 component
3. Gaps → mark `⚠️ Gap` with reason in traceability table
4. Reverse: each component must trace to ≥1 US-* (justify if not: infra/scaffold)
5. **FAIL if** any US-* has zero coverage without justification — fix before presenting

## Update Blueprints

- `{BLUEPRINTS_DIR}/tech.md`: fill D3 placeholders. Preserve existing decisions.
- `{BLUEPRINTS_DIR}/structure.md`: fill structure from implementation.md. Preserve existing.
- Read current files first — never overwrite prior content.
- These are canonical, platform-agnostic (no front-matter); the platform shim references them.

## Update Manifest

Incremental: `units[{unit}].artifacts.design` → `status:"draft"`, files list, decisions at `units[{unit}].decisions.design`
Comprehensive: `artifacts.design` → `status:"draft"`, files list, decisions at `decisions.design`
Versions: `versions: { resolved_at, source: "web-search"|"training-knowledge"|"mixed", map: {...} }`
Steering: `updatedBy.tech` += `design`, `updatedBy.structure` += `design`

## Present Results

```
📍 Design

[Summary]

- **Architecture**: [Style]
- **Stack**: [Frontend] / [Backend] / [Database] / [Infra]
- **Components**: [X] designed
- **Entities**: [Y] modeled
- **Endpoints**: [Z] specified
- **Integrations**: [W] defined
- **Operations**: [Minimal / Standard / Full / Skipped]
- **PBT Properties**: [N] (or "Skipped")
- **Testing Strategy**: [Included / Skipped]
- **NFR**: [Included / Skipped]
{Rewrite scope — add:}
- **Parity**: [X]/[N] entities mapped (fields reconcile: [yes/no]), [Y]/[P] screens, [Z]/[S] operations
- **New deviations this phase**: [D] (appended to deviations.md — approval covers them)

Artifacts at `{SPECS}/{feature}/design.md` (+ `design/` folder if complex).

---
🔲 **Your turn**:
- ✅ "proceed" — move to next phase
- ✏️ "change [what]" — request edits
- ← "back to [requirements/decomposition]" — return to a previous phase
```

**STOP and wait.**

On "back to [phase]": set status `"draft"`, dispatch that phase skill.

On approval:
- Comprehensive: `artifacts.design.status:"approved"`, add `"design"` to `sharedPhases`. Audit. Auto-continue to tasks.
- Incremental: `units[{unit}].artifacts.design.status:"approved"`, add to `completedPhases`. Audit. Return to Unit Dashboard:
  ```
  ✅ {unit} design approved.

  🔲 **Your turn**:
  - ▶️ "tasks" — task breakdown for {unit}
  - 🎯 "start {other-unit}" — design another unit
  - 📋 "show units" — unit dashboard
  ```
  **STOP and wait.**
