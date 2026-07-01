---
name: aidlc-design
description: Technology decisions and architecture design. Generates D3 decision gate, validates choices, produces modular or compact design documents with components, data model, API spec, integration, implementation, correctness, and NFR specifications.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, design, architecture, technology-decisions, components, data-model, api, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Design Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session. This file contains only phase-specific instructions.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You turn requirements into concrete, implementable technical designs. Make technology decisions deliberately — weigh trade-offs, consider team capabilities, plan for evolution.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-design v1.0.0 active — {platform} detected.
Ready to generate technology decisions and architecture design.
```

---

## Output Path Scoping (CRITICAL)

- **Comprehensive mode** (or no units): write to `{SPECS_DIR}/{feature}/`
- **Incremental mode** (designing a specific unit): write to `{SPECS_DIR}/{feature}/units/{unit}/`

**NEVER write unit-scoped artifacts to the shared `{SPECS_DIR}/{feature}/` directory.**

---

## Quick Start

1. Generate D3 decision gate (8-15 questions from tech catalogs) → user fills answers (or "use recommendations")
2. Validate D3 for conflicts → resolve if any
3. Generate design documents (compact for ≤10 stories, modular for 11+)
4. Update steering/tech.md and steering/structure.md
5. Present results → wait for approval → hand off to tasks

**Reads**: context.md (Summary), requirements.md, units.md (if exists), foundation unit design (if exists), steering files, resources.md
**Writes**: decisions-design.md, design.md, design/*, steering/tech.md, steering/structure.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope, feature description | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories with acceptance criteria | Requirements to design for | Markdown (requirements.md), YAML, JSON, CSV, plain text |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Units/boundaries | Decomposition units if complex project | Markdown (units.md) |
| Foundation unit design | Shared conventions from the foundation unit (if it exists and has been designed) | Markdown at `{SPECS_DIR}/{feature}/units/foundation/design/*` |
| Existing API specs | Pre-existing API definitions | OpenAPI (YAML/JSON), GraphQL schema (.graphql/.gql) |
| Existing data models | Pre-existing data schemas | Prisma (.prisma), SQL DDL (.sql), JSON Schema (.json) |
| Design system/component inventory | UI component library or design tokens | Via MCP, URLs, file paths |
| Reverse-engineer analysis | Existing conventions, data model, API surface | `.aidlc/reverse-engineer/conventions.md`, `data-model.md`, `api-surface.md` |

### Special Input Handling
- **OpenAPI spec** → use as basis for `design/api-spec.md`
- **GraphQL schema** → use as basis for `design/api-spec.md`
- **Prisma/SQL DDL** → use as basis for `design/data-model.md`
- **Reverse-engineer** → read `conventions.md` Summary, `data-model.md`, `api-surface.md`

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-design.md | `{WORKFLOW_DIR}/{feature}/decisions-design.md` |
| design.md | `{SPECS_DIR}/{feature}/design.md` |
| design/components.md | `{SPECS_DIR}/{feature}/design/components.md` |
| design/data-model.md | `{SPECS_DIR}/{feature}/design/data-model.md` |
| design/api-spec.md | `{SPECS_DIR}/{feature}/design/api-spec.md` |
| design/integration.md | `{SPECS_DIR}/{feature}/design/integration.md` |
| design/implementation.md | `{SPECS_DIR}/{feature}/design/implementation.md` |
| design/operations.md | `{SPECS_DIR}/{feature}/design/operations.md` (conditional — scope ≠ bugfix/refactor, D3 observability ≠ None) |
| design/correctness.md | `{SPECS_DIR}/{feature}/design/correctness.md` (conditional) |
| design/testing-strategy.md | `{SPECS_DIR}/{feature}/design/testing-strategy.md` (conditional) |
| design/nfr.md | `{SPECS_DIR}/{feature}/design/nfr.md` (conditional) |
| tech.md (update) | `{STEERING_DIR}/tech.md` |
| structure.md (update) | `{STEERING_DIR}/structure.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve inputs:
   - Project context — **read only `## Summary` section**
   - Requirements — **read only `## Summary` section** during init; full content during generation
   - Units (if exists) — **read only `## Summary` section**
   - Foundation unit design (if exists) — read `{SPECS_DIR}/{feature}/units/foundation/design/` Summary sections for shared conventions
5. If steering files exist, read Summary sections from `{STEERING_DIR}/product.md`, `tech.md`, `structure.md`. Read `resources.md` in full.
6. **Partial write detection**: If manifest shows design status = `"approved"` but files missing → set `"partial"`, re-generate missing files only.
7. **Incremental mode**: Scope to unit's stories. Create unit output folders. Write to `units/{unit}/` paths.

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Generate D3 decisions + validate | `{SKILL_DIR}/actions/decision-gate.md` |
| 2 | Generate design documents | `{SKILL_DIR}/actions/generate.md` |
| 3 | Edit (if user requests changes) | `{SKILL_DIR}/actions/edit.md` |

---

## Skill Handoff

**Next skill**: `aidlc-tasks` (on user approval of design).

---

## Phase-Specific Rules

- For incremental mode: write full audit entry to `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md` and a one-line summary to `{WORKFLOW_DIR}/{feature}/audit.md`.
- **Audit actions**: decision-gate, validation, generation, approval, edit.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `artifacts.design.status` (or `units[{unit}].artifacts.design.status` in incremental):
  - Not present → load `actions/decision-gate.md` (start from D3)
  - Check if `decisions-design.md` exists → if yes, load `actions/generate.md`
  - `"draft"` or `"partial"` → load `actions/generate.md` (skip already-written files per manifest `files` list)
  - `"approved"` → phase complete, hand off to tasks
