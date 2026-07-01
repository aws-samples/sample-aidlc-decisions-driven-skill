# AI-DLC v2 — Skill Architecture

## Architecture Overview

AI-DLC v2 uses a **hub-and-spoke** architecture with **layered instruction loading**. Each workflow phase is a self-contained skill with a compact SKILL.md index. The orchestrator reads project state and dispatches to the appropriate skill — but every skill also works independently without the orchestrator.

Skills use a three-layer structure for token efficiency:
1. **`aidlc/shared/base.md`** — loaded once per session (environment detection, manifest ops, behavioral rules)
2. **`SKILL.md`** — compact index loaded on dispatch (~100-140 lines for core skills)
3. **`actions/*.md`** — detailed instructions loaded only when executing that specific step

```
                    ┌─────────────┐
                    │   aidlc     │  ← Orchestrator (dispatches, status, rollback)
                    │ (optional)  │
                    └──────┬──────┘
                           │ dispatches
     ┌──────────┬──────────┼──────────┬──────────┬──────────┬─────────┐
     ▼          ▼          ▼          ▼          ▼          ▼         ▼
┌─────────┐ ┌──────┐ ┌────────┐ ┌──────┐ ┌───────┐ ┌─────────┐ ┌─────┐
│ context │ │ req  │ │ decomp │ │design│ │ tasks │ │implement│ │build│→deploy
│ Phase 1 │ │Phs 2 │ │ Phs 3  │ │Phs 4│ │ Phs 5 │ │ Phase 6 │ │Phs 7│  Phs 8
└────┬────┘ └──┬───┘ └───┬────┘ └──┬───┘ └──┬────┘ └────┬────┘ └─────┘
     │         │         │         │        │            │
     └────→────┘    ┌────┘         │        └────→───────┘──→ build → deploy
              │     │ (incremental)│
              │     └──→ design (per unit)
              │
              └──→ design (comprehensive, skip 3)
              │
              └──→ prototype (standalone side-quest)
```

Each spoke:
- Detects its own environment (Kiro, Claude Code)
- Resolves its own inputs (manifest → user override → conventional path → ask)
- Reads/writes the shared manifest (`aidlc-manifest.yaml`)
- Appends to the shared audit trail
- Produces artifacts at conventional paths

## How to Use

### With the Orchestrator

1. Activate the `aidlc` skill
2. Say "start" to begin a new feature, or "resume" to pick up where you left off
3. The orchestrator loads the next skill's SKILL.md and executes it
4. Each skill chains forward automatically via its Skill Handoff section
5. The workflow continues until complete — you only interact at decision gates and approval checkpoints

The orchestrator handles: dispatching phase skills, status display, resume detection, rollback, incremental mode coordination, and architecture review recommendations.

### Orchestrator Commands

| Command | What It Does |
|---|---|
| `start` | Initialize a new feature → begins context phase |
| `resume` | Read manifest, present current state, continue from where you left off |
| `status` | Show full workflow progress dashboard |
| `next` | Determine and dispatch the next phase (no status presentation) |
| `help` | Explain current position and available options |
| `rollback` | Roll back to a previous phase (marks downstream as outdated) |
| `repair` | Rebuild manifest from disk artifacts (recovery tool) |
| `quick` | Single-pass mode — collapses context + requirements + design + tasks for simple features |
| `doctor` | Verify installation health — checks skills, cross-references, shared resources |
| `prototype` | Build a throwaway spike to validate requirements |
| `review` | Run solutions review (cross-unit) or code review (post-implementation) |
| `reverse-engineer` | Deep brownfield codebase analysis (13 reports) |
| Phase names | Jump directly to any phase: `context`, `requirements`, `decomposition`, `design`, `tasks`, `implement`, `build`, `deploy` |

Commands match loosely — "what's next", "show status", "go back to design" all work.

### Without the Orchestrator

Activate any phase skill directly. Each skill resolves its own inputs:

```
# Start from scratch
Activate aidlc-context → it scans your workspace, creates context.md and manifest

# Pick up mid-workflow
Activate aidlc-design → it reads the manifest (or finds files at conventional paths),
                         loads context + requirements, and runs the design phase

# Standalone prototype
Activate aidlc-prototype → give it stories (inline, file, or from manifest),
                           it builds a throwaway spike
```

Skills find what they need via the input resolution algorithm:
1. Check manifest for registered artifacts
2. Check if user provided a path ("use X as requirements")
3. Check conventional paths (`{SPECS_DIR}/{feature}/requirements.md`)
4. Scan for matching files
5. Ask the user

## Skill List

| Skill | Phase | Description |
|---|---|---|
| `aidlc-context` | 1 | Scans workspace, gathers project context, creates manifest and steering files |
| `aidlc-requirements` | 2 | Translates context into user stories with EARS acceptance criteria. Includes routing recommendation (decompose vs design vs prototype) |
| `aidlc-decomposition` | 3 | Breaks complex projects into implementation units with boundaries and dependencies. Proposes a foundation unit for shared scaffolding when needed. Presents incremental vs comprehensive mode choice |
| `aidlc-design` | 4 | Creates technical design — components, data model, API spec, integration patterns, implementation plan, operations design (logging, health, metrics). Supports compact (simple) and full (complex) formats |
| `aidlc-tasks` | 5 | Breaks design into sequenced implementation tasks with execution waves and file ownership |
| `aidlc-implement` | 6 | Executes tasks — standard (sequential), parallel (wave-based), or autonomous mode |
| `aidlc-build` | 7 | Detects build tooling, runs final integration build, executes full test suites, validates quality gates |
| `aidlc-deploy` | 8 | Generates CI/CD pipeline configs and optional IaC (Terraform/CDK) via D5 decision gate. Platform-specific templates for GitHub Actions, GitLab CI. Handles environment promotion, secrets, rollback, migrations |
| `aidlc-prototype` | — | Standalone throwaway spike. Builds minimal code to validate requirements. Not a workflow phase |
| `aidlc-solutions-review` | — | Cross-unit design review. Compares designs for conflicts, inconsistencies, and alignment issues. Produces severity-classified report |
| `aidlc-code-review` | — | Code review against design specs, security, performance, test coverage, and coding standards. Produces actionable findings with suggested fixes |
| `aidlc` | — | Workflow orchestrator. Reads manifest, dispatches to phase skills, manages rollback and status. Executes phases by loading skill SKILL.md files |

## File-System Contract

### What Each Skill Reads

| Skill | Reads |
|---|---|
| `aidlc-context` | Workspace files (source, configs, README) |
| `aidlc-requirements` | context.md (Summary), steering files (Summaries), resources.md (full), design resources |
| `aidlc-decomposition` | context.md (Summary), requirements.md, personas.md |
| `aidlc-design` | context.md (Summary), requirements.md, units.md (if exists), steering files (Summaries), resources.md, design resources |
| `aidlc-tasks` | context.md (Summary), design.md + design/*, steering files (Summaries) |
| `aidlc-implement` | tasks.md, design.md + design/*, steering files (Summaries), design resources |
| `aidlc-build` | Source code, build configs (package.json, Makefile, etc.), design/testing-strategy.md, steering files |
| `aidlc-deploy` | build-report.md, design/implementation.md, design/operations.md (if exists), context.md, existing CI configs, steering files |
| `aidlc-prototype` | requirements.md (or inline stories), design resources |
| `aidlc-solutions-review` | 2+ unit design docs (design.md + design/*), units.md, context.md |
| `aidlc-code-review` | Source code, optionally: design docs, tasks.md, git diff |
| `aidlc` (orchestrator) | aidlc-manifest.yaml, audit.md, context.md (diagram), artifact files (for counts) |

### What Each Skill Writes

| Skill | Writes |
|---|---|
| `aidlc-context` | context.md, steering/*, manifest (creates), audit.md (creates), `.claude/CLAUDE.md` (Claude Code only) |
| `aidlc-requirements` | decisions-requirements.md, requirements.md, personas.md, steering/product.md (update) |
| `aidlc-decomposition` | decisions-units.md, units.md |
| `aidlc-design` | decisions-design.md, design.md, design/*, steering/tech.md + structure.md (update) |
| `aidlc-tasks` | decisions-tasks.md, tasks.md |
| `aidlc-implement` | Source code, test files, tasks.md (checkbox updates) |
| `aidlc-build` | `{WORKFLOW_DIR}/{feature}/build-report.md` |
| `aidlc-deploy` | decisions-deploy.md, pipeline configs, Dockerfile, environment configs, IaC (infra/), deploy scripts, `{WORKFLOW_DIR}/{feature}/deploy-summary.md` |
| `aidlc-prototype` | `.aidlc/prototype/{feature}/` (throwaway code + README) |
| `aidlc-solutions-review` | `{WORKFLOW_DIR}/{feature}/architecture-review.md` |
| `aidlc-code-review` | `{WORKFLOW_DIR}/{feature}/code-review.md` |
| `aidlc` (orchestrator) | aidlc-manifest.yaml (rollback), context.md (diagram progress) |

### Path Conventions

```
{SPECS_DIR}/{feature}/              # Spec artifacts (context, requirements, design, tasks)
{WORKFLOW_DIR}/{feature}/           # Workflow state (manifest, decisions, audit)
{STEERING_DIR}/                     # Cross-feature steering files
.aidlc/prototype/{feature}/         # Throwaway prototype code
```

Where `SPECS_DIR` is always `.aidlc/specs`, `STEERING_DIR` is platform-dependent (`.kiro/steering`, `.claude/rules`), and `WORKFLOW_DIR` is always `.aidlc/workflow`.

## Manifest Overview

The manifest (`aidlc-manifest.yaml`) is the single source of truth for workflow state. It lives at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`.

**Key sections:**
- `state` — shared phases, mode (incremental/comprehensive)
- `artifacts` — shared phase artifacts (context, requirements, decomposition) with `status`, `timestamp`, `files`
- `context-summary` — key fields from context.md for downstream skills
- `decisions` — shared decision summaries (requirements, decomposition, deploy). Unit-scoped decisions in `units[].decisions`
- `steering` — `updatedBy` map tracking which phases updated each steering file
- `units[]` — per-unit state for incremental mode: `status`, `phase`, `completedPhases`, `implementationMode`, `implementation` (task counters), `artifacts`, `decisions`. Multiple units can be `in-progress` simultaneously.

**v2.2 conventions:**
- Shared phases tracked in `state.sharedPhases`. Per-unit phases in `units[].phase` + `units[].completedPhases`
- Parallel units supported — different sessions can work on different units
- Comprehensive mode uses `state.sharedPhases` for all phases; `units[]` stays empty
- Artifacts grouped by phase, not by file
- Decision gate files implicit, not tracked
- `format` and `producedBy` dropped

**Created by**: `aidlc-context` (Phase 1)
**Read by**: Every skill on startup
**Updated by**: Every skill after producing artifacts

## Workflow Paths

### Comprehensive (Simple → Medium Projects)

```
context → requirements → [decomposition] → design → tasks → implement → build → deploy
```

Decomposition is recommended for complex projects (5+ stories, 2+ domains) but can be skipped.

### Incremental (Complex Projects)

```
context → requirements → decomposition
  → for each unit: design → tasks → implement
  → build → deploy
```

The decomposition skill proposes a foundation unit (first in sequence) when shared scaffolding is needed. Brownfield projects that already have established conventions simply won't have a foundation unit proposed.

Units are processed sequentially. Architecture review is recommended after 2+ unit designs are complete. Build and deploy run once after all units are implemented.

### Prototype (Side-Quest)

```
requirements → prototype → [update requirements] → continue workflow
```

The prototype is standalone — it doesn't advance the workflow phase. It produces throwaway code in `.aidlc/prototype/` and reports discoveries that may feed back into requirements.

### With Reviews

```
context → requirements → [decomposition]
  → design → [solutions review] → tasks → implement → [code review] → build → deploy
```

Reviews are optional but recommended:
- **Solutions review**: after 2+ unit designs complete (incremental mode)
- **Code review**: after implementation, before build/deploy

## Testing Strategy

Each skill is independently testable. The pattern:

1. **Create fixture files** at conventional paths (or provide inline)
2. **Activate the skill** — it resolves inputs from fixtures
3. **Assert outputs** — check that expected artifacts were created with correct content
4. **Check manifest** — verify artifact registration and state updates

### Example: Testing aidlc-design in Isolation

```
# Setup fixtures
.aidlc/specs/my-feature/context.md      ← minimal context
.aidlc/specs/my-feature/requirements.md ← 3 user stories
.aidlc/workflow/my-feature/aidlc-manifest.yaml ← state: requirements complete

# Activate aidlc-design
# → It reads manifest, finds context + requirements, runs design phase

# Assert
# → design.md created at .aidlc/specs/my-feature/design.md
# → manifest updated with design artifact, design added to sharedPhases
# → audit.md has design entries
```

### Testing Without Manifest

Skills also work without a manifest (fallback to conventional paths):

```
# Setup — just drop files, no manifest
.aidlc/specs/my-feature/context.md
.aidlc/specs/my-feature/requirements.md

# Activate aidlc-design
# → No manifest found, falls back to conventional paths
# → Finds context.md and requirements.md
# → Creates manifest after producing output
```

### Testing with Non-Standard Inputs

```
# User provides YAML requirements instead of markdown
docs/stories.yaml ← YAML-formatted user stories

# Activate aidlc-design, tell it: "use docs/stories.yaml as requirements"
# → Skill reads YAML, parses stories, registers in manifest as user-provided
# → Proceeds normally
```
