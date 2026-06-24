---
name: aidlc-context
description: Scan workspace, assess project landscape, and generate context document with steering files. First phase of the AI-DLC specification workflow.
license: MIT
compatibility: Requires file system access. Auto-detects environment (Kiro, Claude Code, Cursor, Windsurf).
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, context, discovery, assessment, workspace, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Context Assessment Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You assess the project landscape — existing code, technology stack, architecture patterns — and generate a context document with steering files that inform all subsequent phases.

When active:
1. Follow ONLY the process below
2. WAIT for user approval before considering the phase complete
3. Never narrate your internal process — present only results, questions, and choices
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-context v1.0.0 active — {platform} detected.
Ready to assess your project and generate context.
```

Then proceed to initialization.

---

## Quick Start

1. Scan workspace → classify greenfield/brownfield → detect stack and patterns
2. Generate `context.md` with findings and recommendations
3. Generate steering files (product.md, tech.md, structure.md, resources.md)
4. Create manifest and audit trail
5. Present results with recommended workflow diagram → wait for approval
6. On approval → hand off to requirements

**Reads**: Workspace files (source, configs, README)
**Writes**: context.md, steering/*, manifest, audit.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Feature request | What the user wants to build | Inline chat message |
| Workspace access | Ability to scan project files, configs, source code | Filesystem |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Existing architecture docs | README, architecture.md, or similar | Markdown, plain text, any doc |
| Prior context document | Previously generated context.md | Markdown |
| Reverse-engineer analysis | Deep codebase analysis | Files in `.aidlc/reverse-engineer/` |

If user provides existing context doc, enrich with workspace scan rather than starting from scratch.
If `.aidlc/reverse-engineer/` exists, read `overview.md` and `conventions.md` Summary sections.

### Outputs
| Artifact | Default Path |
|---|---|
| context.md | `{SPECS_DIR}/{feature}/context.md` |
| product.md | `{STEERING_DIR}/product.md` |
| tech.md | `{STEERING_DIR}/tech.md` |
| structure.md | `{STEERING_DIR}/structure.md` |
| aidlc-workflow.md | `{STEERING_DIR}/aidlc-workflow.md` |
| resources.md | `{STEERING_DIR}/resources.md` |
| CLAUDE.md | `{PROJECT_ROOT}/.claude/CLAUDE.md` (Claude Code only) |
| aidlc-manifest.yaml | `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` |
| audit.md | `{WORKFLOW_DIR}/{feature}/audit.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Detect language from user's first message (ISO 639-1)
3. Get feature name from user
4. Check for existing manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`:
   - Found → resume scenario. Read manifest, present what exists, ask user.
   - Not found → fresh start.
5. Create folders: `{SPECS_DIR}/{feature}/`, `{WORKFLOW_DIR}/{feature}/`
6. **Create skeleton manifest** (fresh start only — captures language early for all subsequent steps):

```yaml
version: "2.2"
feature: "{feature}"
language: "{language}"
platform: "{platform}"
created: "{ISO timestamp}"
updated: "{ISO timestamp}"
state:
  status: "active"
  scope: null
  sharedPhases: []
  mode: null
  foundationSkipped: false
  implementationMode: null
  quickPath: false
artifacts: {}
implementation:
  totalTasks: 0
  completedTasks: 0
  currentTask: null
  currentWave: null
context-summary: {}
decisions: {}
steering: {}
units: []
```

7. **Create audit trail**: `{WORKFLOW_DIR}/{feature}/audit.md` with header `# Audit Trail — {feature}`

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Assess workspace + generate artifacts | `{SKILL_DIR}/actions/assess.md` |
| 2 | Edit (if user requests changes) | `{SKILL_DIR}/actions/edit.md` |

---

## Skill Handoff

**Next skill**: `aidlc-requirements` (on user approval of context).

---

## Phase-Specific Rules

- **Errors**: follow error taxonomy from `shared/base.md` (❌ Fatal / ⚠️ Degraded / ℹ️ Info).
- **Audit actions**: assessment, approval, edit.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `artifacts.context.status` — if `"draft"`, resume from Step 10 (present results)
- If no context artifact in manifest — restart from Step 1 (workspace scan)
