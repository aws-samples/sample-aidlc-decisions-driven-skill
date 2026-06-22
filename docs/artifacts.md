# Artifacts

AI-DLC produces artifacts at conventional paths. All paths are platform-aware.

## Spec Artifacts (`{SPECS_DIR}/{feature}/`)

| File | Produced By | Description |
|---|---|---|
| `context.md` | aidlc-context | Project landscape, stack, architecture, feature impact |
| `requirements.md` | aidlc-requirements | User stories with EARS acceptance criteria |
| `personas.md` | aidlc-requirements | User personas (conditional) |
| `units.md` | aidlc-decomposition | Unit boundaries, dependencies, development sequence |
| `design.md` | aidlc-design | Architecture overview and design summary |
| `design/components.md` | aidlc-design | Component breakdown |
| `design/data-model.md` | aidlc-design | Entity definitions, schemas, relationships |
| `design/api-spec.md` | aidlc-design | Endpoint specifications |
| `design/integration.md` | aidlc-design | External service and inter-unit integration |
| `design/implementation.md` | aidlc-design | Directory structure, conventions, project config |
| `design/correctness.md` | aidlc-design | Property-based testing properties (conditional) |
| `design/testing-strategy.md` | aidlc-design | Testing architecture, frameworks, coverage mapping (conditional) |
| `design/nfr.md` | aidlc-design | Non-functional requirements (conditional) |
| `tasks.md` | aidlc-tasks | Sequenced tasks with execution waves |

## Workflow Artifacts (`{WORKFLOW_DIR}/{feature}/`)

| File | Description |
|---|---|
| `aidlc-manifest.yaml` | Single source of truth for workflow state |
| `audit.md` | Chronological log of all actions taken |
| `decisions-{phase}.md` | Decision gate answers (one per phase that has a gate) |
| `architecture-review.md` | Solutions review findings |
| `code-review.md` | Code review findings |
| `build-report.md` | Build results, test results, quality gate status |
| `deploy-summary.md` | Deployment configuration summary |

Decision gate files are produced implicitly by each phase — they're not tracked in the manifest.

## Steering Files (`{STEERING_DIR}/`)

| File | Description |
|---|---|
| `product.md` | Product overview, target users, key features |
| `tech.md` | Technology stack, conventions, patterns |
| `structure.md` | Project directory structure and key files |
| `aidlc-workflow.md` | Workflow state reference for context recovery |
| `resources.md` | External resources (design tools, API specs, docs) |

## Path Variables

| Variable | Kiro | Claude Code |
|---|---|---|
| `SPECS_DIR` | `.aidlc/specs` | `.aidlc/specs` |
| `STEERING_DIR` | `.kiro/steering` | `.claude/steering` |
| `WORKFLOW_DIR` | `.aidlc/workflow` | `.aidlc/workflow` |

## Incremental Mode Paths

In incremental mode, per-unit artifacts are scoped:
- Design: `{SPECS_DIR}/{feature}/units/{unit}/design/*.md`
- Tasks: `{SPECS_DIR}/{feature}/units/{unit}/tasks.md`
- Decisions: `{WORKFLOW_DIR}/{feature}/units/{unit}/decisions-*.md`
- Audit: `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md`
