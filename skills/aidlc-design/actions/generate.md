# Action: design-generation

## Step 0: Resolve Output Paths

Before generating anything, compute and lock the output paths for this run:

```
IF incremental mode (unit is set):
  DESIGN_OUT = {SPECS_DIR}/{feature}/units/{unit}/
  DESIGN_DETAIL_OUT = {SPECS_DIR}/{feature}/units/{unit}/design/
  DECISIONS_OUT = {WORKFLOW_DIR}/{feature}/units/{unit}/
ELSE (comprehensive or no units):
  DESIGN_OUT = {SPECS_DIR}/{feature}/
  DESIGN_DETAIL_OUT = {SPECS_DIR}/{feature}/design/
  DECISIONS_OUT = {WORKFLOW_DIR}/{feature}/
```

Create the output directories if they don't exist. All file writes in this action use these resolved paths — no exceptions.

## Step 0.5: Version Resolution

After D3 choices are locked, resolve the **current stable version** for each selected technology before generating design documents.

**Process**:
1. Extract all technology choices from D3 (manifest `decisions.design` or Decisions Summary)
2. For each tool/framework/library chosen, use **web search** or **package registry lookup** to find the latest stable release:
   - npm registry → Node.js/TypeScript ecosystem (Express, Prisma, Zod, Jest, etc.)
   - PyPI → Python ecosystem (FastAPI, SQLAlchemy, pytest, etc.)
   - Maven Central → Java/Kotlin ecosystem (Spring Boot, JUnit, etc.)
   - crates.io → Rust ecosystem
   - Go module proxy → Go ecosystem
   - Official release pages → runtimes (Node.js, Python, Go, Java), databases (PostgreSQL, MySQL), IaC tools (Terraform, CDK)
3. Record resolved versions as a **version map**: `{tool}: {major.minor.patch}`
4. Use these resolved versions in ALL subsequent design documents (implementation.md, components.md, etc.)

**Fallback** (web search unavailable or fails):
- Use training-data knowledge for version numbers
- Mark each unverified version with `⚠️ unverified` in the version map
- Add a note in the design summary: "Some versions could not be verified against live registries"

**Priority targets** (resolve these first — most impactful for downstream correctness):
- Language/runtime version (Node.js, Python, Java, Go)
- Primary framework (Express, NestJS, FastAPI, Spring Boot, etc.)
- ORM / database client (Prisma, TypeORM, SQLAlchemy, etc.)
- Database engine version (PostgreSQL, MySQL, MongoDB)
- Test runner (Jest, Vitest, pytest, JUnit)
- IaC tool (CDK, Terraform, Pulumi) if applicable
- Build tool (Vite, Webpack, esbuild) if applicable

**Rules**:
- Only resolve tools that were explicitly chosen in D3 — do not add new dependencies
- Prefer LTS releases over bleeding-edge when both are available (e.g., Node.js LTS over Current)
- If a tool has a recently released major version (< 3 months old) with limited ecosystem support, prefer the previous stable major unless D3 explicitly chose the new one
- Store the version map in the manifest under `versions` (see Update Manifest section)

---

## Choose Format

- **Simple** (≤10 stories AND single domain) → compact `design.md` using `{ASSETS_DIR}/design-compact.md`
- **Complex** (11+ stories OR multiple domains) → modular `design.md` + `design/` folder

## External Resources (Conditional)

If `{STEERING_DIR}/resources.md` exists and lists available resources (not "none"):
- **Design tool**: Use design tool MCP (if available) to read component inventory, design tokens → incorporate into design/components.md
- **API specs**: Read OpenAPI/GraphQL schemas → use as basis for design/api-spec.md instead of designing from scratch
- **Design system docs**: Read referenced docs → align component naming and patterns
- **Reference implementations**: Read referenced repos → align architecture patterns
- **Package registries** (for Step 0.5 Version Resolution): Use web search or registry tools to look up latest stable versions. Target registries by ecosystem:
  - **npm** (npmjs.com) → Node.js / TypeScript dependencies
  - **PyPI** (pypi.org) → Python dependencies
  - **Maven Central** (search.maven.org) → Java / Kotlin dependencies
  - **crates.io** → Rust dependencies
  - **pkg.go.dev** → Go modules
  - **NuGet** (nuget.org) → .NET dependencies
  - **Official release pages** → runtimes (nodejs.org, python.org), databases (postgresql.org), IaC tools
  - If no web search or registry tools are available, fall back to training-data knowledge and mark versions as `⚠️ unverified`
- Cite external sources in design documents

## Writing Strategy

1. Read all needed templates + input artifacts in one `readMultipleFiles` call
2. Write independent design detail files in parallel (same turn):
   - `design/components.md`, `design/data-model.md`, `design/api-spec.md` simultaneously
   - `design/integration.md`, `design/implementation.md` simultaneously
   - `design/testing-strategy.md` (if D3 includes testing choices and project ≠ prototype/no-testing)
   - `design/nfr.md` (if applicable), `design/correctness.md` (if applicable)
3. **Checkpoint after each file write**: Update manifest `artifacts.design.files` to include the just-written file and set `artifacts.design.status` to `"partial"`. This enables context recovery to skip already-written files.
4. Write `design.md` last (it references the detail files — keep it slim: Summary + Architecture + Traceability + References only)
5. After all files written, update manifest status from `"partial"` to `"draft"`

## No-Assumptions Rule

**CRITICAL**: ONLY use choices from D3. Read decisions from manifest `decisions.design` section. Fall back to reading `## Decisions Summary` from the decisions file if manifest section is missing. Do not parse the full question/answer blocks. Use `[TBD - not decided in D3]` for any missing decisions. Never assume technology choices that weren't explicitly decided.

## Load Guides Conditionally

Load ONLY the guides that apply from `{REFERENCES_DIR}/`. Do NOT read guides that don't match.

| Guide | Load When |
|---|---|
| `architecture-patterns.md` | **ALWAYS** |
| `api-design.md` | D3 includes API design choices (REST/GraphQL/gRPC) |
| `frontend-architecture.md` | D3 includes frontend framework choice |
| `mobile-architecture.md` | D3 includes mobile platform choice |
| `distributed-patterns.md` | Architecture = microservices or distributed system |
| `property-based-testing.md` | D3 PBT answer = Yes |

**Testing strategy generation**: If D3 includes any testing framework choices (unit, integration, E2E, load, API testing) AND project is not "prototype/no-testing", generate `design/testing-strategy.md` using `{ASSETS_DIR}/design-testing-strategy.md` template. Read the D3 testing answers to populate frameworks, and cross-reference `design/components.md` + `design/api-spec.md` for coverage mapping.

**SKIP all non-matching guides.** For a simple backend API project, load only `architecture-patterns.md` and `api-design.md` (~8KB instead of ~25KB).

**Stack-aware selective reading**: When loading `architecture-patterns.md` or `api-design.md`, read ONLY sections relevant to the chosen stack from D3 (e.g., for TypeScript/Express, skip Java Spring patterns and Go Gin patterns). If a guide has language-specific subsections, read only the matching one.

## Templates

- Simple: `{ASSETS_DIR}/design-compact.md` ONLY
- Complex: `{ASSETS_DIR}/design.md` + modular templates:
  - `{ASSETS_DIR}/design-components.md`
  - `{ASSETS_DIR}/design-data-model.md`
  - `{ASSETS_DIR}/design-api-spec.md`
  - `{ASSETS_DIR}/design-integration.md`
  - `{ASSETS_DIR}/design-implementation.md`
  - `{ASSETS_DIR}/design-testing-strategy.md` — ONLY if D3 includes testing choices AND project ≠ prototype/no-testing
  - `{ASSETS_DIR}/design-correctness.md` — ONLY if PBT selected
  - `{ASSETS_DIR}/nfr.md` — ONLY if NFR questions answered

## Validate

- ✅ All components, entities, endpoints, integrations designed
- ✅ All D3 choices used, no assumptions beyond D3
- ✅ Design files reference each other correctly
- ✅ Cross-references between design files are correct
- ✅ Testing strategy covers all D3 testing choices (if testing-strategy.md generated)
- ✅ Test directory structure in testing-strategy.md is consistent with implementation.md
- ✅ **Version pinning**: All dependencies in implementation.md use specific stable versions from the version map (Step 0.5). No "latest", no unpinned ranges. Versions marked `⚠️ unverified` are acceptable but must retain the marker.
- ✅ **No EOL/deprecated versions**: No dependency uses a version that has reached end-of-life or been officially deprecated. If detected during version resolution, flag and substitute with the current stable alternative.
- ✅ **Traceability complete** (see Traceability Gap Detection below)

## Traceability Gap Detection

After generating all design files, run this check BEFORE presenting results to the user:

1. **Extract all requirement IDs**: Read `requirements.md` (or unit-scoped requirements), collect every `US-*` ID
2. **Scan design output**: Check the Traceability section in `design.md` for each US-* ID
3. **Classify coverage**:
   - **Covered**: US-* appears in traceability table with at least one component mapped
   - **Gap**: US-* does not appear, or appears with no component/endpoint/entity mapped
4. **If gaps exist**: Mark them as `⚠️ Gap` in the traceability table with a brief reason (deferred to another unit, out of scope for this design, handled by shared infrastructure, etc.)
5. **Reverse check**: For each component in `design/components.md`, verify it traces to at least one US-*. Components without a requirement must be justified (infrastructure, shared utilities, framework scaffolding)

**Fail condition**: If any US-* has no design coverage AND no documented justification, do NOT present results. Instead, fix the gap by either:
- Adding the missing component/endpoint/entity to the design
- Documenting why the gap is intentional (deferred, covered elsewhere)

Then proceed to present results.

## Update Steering

After generating design documents, update steering files with D3 decisions:

**`{STEERING_DIR}/tech.md`**: Fill "Pending D3 decisions" placeholders with actual choices. Do NOT overwrite previously settled decisions from earlier features or workflow runs.

**`{STEERING_DIR}/structure.md`**: Fill "will be defined during design phase" placeholders with actual structure from `design/implementation.md`. Do NOT overwrite previously documented structure.

Read current steering files first, preserve all existing content, update only the placeholder sections or append new entries.

## Update Manifest

- **Incremental mode**: Add `units[{unit}].artifacts.design` entry: `status: "draft"`, `timestamp`, `files` listing all generated design files. Write design decisions to `units[{unit}].decisions.design`.
- **Comprehensive mode**: Add top-level `artifacts.design` entry: `status: "draft"`, `timestamp`, `files`. Write design decisions to top-level `decisions.design`.
- **Version resolution metadata**: Add a `versions` section to the manifest (top-level for comprehensive, under `units[{unit}]` for incremental):
  ```yaml
  versions:
    resolved_at: "{ISO timestamp}"
    source: "web-search" | "training-knowledge" | "mixed"
    map:
      express: "5.1.0"
      prisma: "6.2.1"
      node: "22.15.0"
      # ... one entry per resolved tool
  ```
  - `source: "web-search"` — all versions confirmed via live registry lookup
  - `source: "training-knowledge"` — all versions from model knowledge (no web access)
  - `source: "mixed"` — some verified, some not (individual entries marked `⚠️ unverified` in design docs)
- Update `steering.updatedBy.tech` to include `design`
- Update `steering.updatedBy.structure` to include `design`

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
- **PBT Properties**: [N] (or "Skipped")
- **Testing Strategy**: [Included / Skipped]
- **NFR**: [Included / Skipped]

Artifacts at `{SPECS_DIR}/{feature}/design.md` (+ `design/` folder if complex).

---
🔲 **Your turn**:
- ✅ "proceed" — move to next phase
- ✏️ "change [what]" — request edits
- ← "back to [requirements/decomposition]" — return to a previous phase
```

**STOP and wait for approval.**

On "back to [phase]": Set current design artifact status to `"draft"`. Dispatch the named phase skill.

On approval: update manifest — **incremental mode**: set `units[{unit}].artifacts.design.status` to `"approved"`, set `units[{unit}].phase` to `"design"`, add `"design"` to `units[{unit}].completedPhases`. **Comprehensive mode**: set `artifacts.design.status` to `"approved"`, add `"design"` to `state.sharedPhases`. Append audit entry.

**Handoff after approval**:
- **Comprehensive mode**: Auto-continue to tasks.
- **Incremental mode**: Do NOT auto-continue. Return to the orchestrator's Unit Dashboard. Present:
  ```
  ✅ {unit} design approved.

  🔲 **Your turn**:
  - ▶️ "tasks" — continue to task breakdown for {unit}
  - 🎯 "start {other-unit}" — begin design for another unit
  - 📋 "show units" — see the unit dashboard
  ```
  **STOP and wait.** The user decides what happens next — not the workflow.
