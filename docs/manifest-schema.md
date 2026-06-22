# Manifest Schema (v2.2)

The manifest is the single source of truth for workflow state. It lives at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`.

## Full Example

```yaml
version: "2.2"
feature: "notifications"
language: "en"
platform: "kiro"
created: "2026-04-15T10:00:00Z"
updated: "2026-04-15T11:30:00Z"

state:
  sharedPhases: [context, requirements, decomposition]
  mode: incremental              # null | incremental | comprehensive
  status: active                 # active | completed
  implementationMode: null       # null | standard | parallel | autonomous (comprehensive mode only)
  quickPath: false               # true if created via quick mode

# Top-level implementation tracking (comprehensive mode only; incremental uses units[].implementation)
implementation:
  totalTasks: 0
  completedTasks: 0
  currentTask: null
  currentWave: null

artifacts:
  context:
    status: approved
    timestamp: "2026-04-15T10:00:00Z"
    files: [context.md]
  requirements:
    status: approved
    timestamp: "2026-04-15T10:30:00Z"
    files: [requirements.md, personas.md]
  decomposition:
    status: approved
    timestamp: "2026-04-15T11:00:00Z"
    files: [units.md]
  # Comprehensive mode also has: design, tasks, build, deploy (same structure)

context-summary:
  type: Greenfield
  stack: "TypeScript / NestJS / PostgreSQL"
  architecture: "Modular Monolith"
  feature: "E-commerce platform"
  impact: "New standalone"
  complexity: High
  teamSize: small                # solo | small | medium | large — captured in D1
  recommendations: { personas: true, units: true, nfr: true }

decisions:
  requirements: { scope: "Full product", user-types: 3, integrations: 2 }
  decomposition: { strategy: "domain-driven", units: 3 }
  # Comprehensive mode also has: design, tasks, deploy (same structure)

steering:
  updatedBy:
    product: [context, requirements]
    tech: [context, design]
    structure: [context, design]

units:
  - name: auth
    status: in-progress
    phase: implement
    completedPhases: [design, tasks]
    implementationMode: standard
    implementation: { totalTasks: 12, completedTasks: 8, currentTask: "3.2", currentWave: null }
    artifacts:
      design: { status: approved, timestamp: "...", files: [design.md, design/components.md] }
      tasks: { status: approved, timestamp: "...", files: [tasks.md] }
    decisions:
      design: { api-style: "REST", database: "PostgreSQL" }
      tasks: { breakdown: "vertical-slice", testing: "test-after" }
  - name: notifications
    status: in-progress
    phase: design
    completedPhases: []
    implementationMode: null
    implementation: { totalTasks: 0, completedTasks: 0, currentTask: null, currentWave: null }
    artifacts:
      design: { status: draft, timestamp: "...", files: [design.md] }
    decisions:
      design: { api-style: "REST" }
  - name: payments
    status: not-started
    phase: null
    completedPhases: []
    implementationMode: null
    implementation: { totalTasks: 0, completedTasks: 0, currentTask: null, currentWave: null }
    artifacts: {}
    decisions: {}
```

## Conventions

- **Shared vs. per-unit**: `state.sharedPhases` tracks project-wide phases. Per-unit phases live in `units[].phase` and `units[].completedPhases`.
- **Parallel units**: Multiple units can be `in-progress` simultaneously — different sessions work on different units.
- **Comprehensive mode**: `units[]` stays empty. Design/tasks/implement tracked in `state.sharedPhases`. Implementation mode stored in `state.implementationMode`. Task progress tracked in top-level `implementation`.
- File paths in `files` are relative to `{SPECS_DIR}/{feature}/` (shared) or `{SPECS_DIR}/{feature}/units/{unit}/` (per-unit).
- Decision gate files (`decisions-{phase}.md`) are implicit — not tracked in artifacts.
- Steering paths are implicit (`{STEERING_DIR}/{name}.md`) — only `updatedBy` is tracked.
- `context-summary` stores key fields from context.md for downstream skills. `teamSize` is captured in D1 and used by D2/D3 validation rules.
- `decisions` stores compact summaries — shared decisions at top level, unit-scoped in `units[].decisions`.

## Lifecycle

- **Created by**: `aidlc-context` (Phase 1)
- **Read by**: Every skill on startup
- **Updated by**: Every skill after producing artifacts
