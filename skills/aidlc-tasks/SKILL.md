---
name: aidlc-tasks
description: Bridge design to implementation. Break design documents into concrete, sequenced, estimable tasks with execution waves for parallel dispatch.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  author: AI-DLC Maintainers
  keywords: specification, tasks, implementation, planning, execution-waves, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Tasks Skill

> **Base**: `shared/base.md` (full on first load, §Summary on chain). **Actions**: load per-step from `actions/`.

You bridge architecture and implementation. Break design documents into concrete, sequenced, estimable tasks. Think about dependencies, parallelism, and risk. Size tasks for 1-2 days and sequence to avoid blocking.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-tasks active — {platform} detected.
Ready to generate implementation tasks from design documents.
```

---

## Output Path Scoping (CRITICAL)

Per shared base — use unit-scoped paths in incremental mode.

---

## Quick Start

1. Generate D4 decision gate → user fills answers (or "use recommendations")
2. Validate D4 for conflicts → resolve if any
3. Generate sequenced tasks with execution waves and file ownership
4. Validate: all components covered, no circular deps, no file ownership overlaps
5. Present results → wait for approval → hand off to implement

**Reads**: context.md (Summary), design.md + design/*, testing-strategy.md (if exists), blueprints
**Writes**: decisions-tasks.md, tasks.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope | Markdown (context.md), YAML, JSON, plain text, inline |
| Design documents | Components, data model, APIs, integrations, implementation plan | Markdown (design/*.md), YAML, JSON |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Units | Decomposition units if project was decomposed | Markdown, YAML, JSON |
| NFR specs | Non-functional requirements | Markdown, YAML, JSON |
| Testing strategy | Testing architecture, frameworks, coverage mapping | Markdown (design/testing-strategy.md) |
| Existing task list | Pre-existing tasks to validate and enrich | Markdown, YAML, JSON, plain text |

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-tasks.md | `{WORKFLOW_DIR}/{feature}/decisions-tasks.md` |
| tasks.md | `{SPECS_DIR}/{feature}/tasks.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve design documents (manifest → conventional path → ask)
5. If blueprints exist, read Summary sections. Read `resources.md` in full.
6. **Incremental mode**: Scope to unit's design at `{SPECS_DIR}/{feature}/units/{unit}/design/*`

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Generate D4 decisions + validate | `{SKILL_DIR}/actions/decision-gate.md` |
| 2 | Generate tasks + execution waves | `{SKILL_DIR}/actions/generate.md` |
| 3 | Edit (if user requests changes) | `{SKILL_DIR}/actions/edit.md` |

---

## References

For task strategies, read `{SKILL_DIR}/references/task-strategies.md` when generating.
For operations guidance, read `{SKILL_DIR}/references/operations.md` for infra/deploy tasks.

---

## Skill Handoff

**Next skill**: `aidlc-implement` (on user approval of tasks).

---

## Phase-Specific Rules

- For incremental mode: write full audit entry to `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md` and a one-line summary to `{WORKFLOW_DIR}/{feature}/audit.md`.
- **Audit actions**: decision-gate, validation, generation, approval, edit.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `artifacts.tasks.status` (or `units[{unit}].artifacts.tasks.status`):
  - Not present → load `actions/decision-gate.md` (start from D4)
  - Check if `decisions-tasks.md` exists → if yes, load `actions/generate.md`
  - `"draft"` → load `actions/generate.md` (re-present results for approval)
  - `"approved"` → phase complete, hand off to implement
