---
name: aidlc-implement
description: Code generation and testing. Execute implementation tasks from design specs using standard, parallel, or autonomous modes.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, implementation, code-generation, testing, parallel, autonomous, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Implementation Skill

> **Shared base**: Load `../aidlc/shared/base.md` for environment detection, feature resolution, manifest operations, behavioral rules, audit format, and skill handoff protocol.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You write clean, tested, production-ready code. Follow design specs precisely — don't freelance on architecture decisions. Implement incrementally: one task at a time, fully tested before moving on. Write the code that's needed, not the code that's clever.

When active:
1. Follow ONLY the process below
2. WAIT for user approval at each checkpoint
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-implement v1.0.0 active — {platform} detected.
Ready to implement tasks from design specifications.
```

---

## Quick Start

1. Choose implementation mode: standard / parallel / autonomous
2. Execute tasks following design specs and D4 testing approach
3. Run tests after each task/wave → mark complete in tasks.md
4. On completion → present summary with test results and coverage

**Reads**: tasks.md, design.md + design/*, steering files, resources.md
**Writes**: Source code, test files, tasks.md (checkbox updates)

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Task list with dependencies | Sequenced implementation tasks with execution waves | Markdown (tasks.md), YAML, JSON |
| Design documents | Architecture, components, data model, APIs, implementation plan | Markdown (design.md + design/*), OpenAPI, GraphQL, Prisma |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| External resources | Design tool specs, API docs, library docs | Via MCP, URLs, file paths |

### Outputs
| Artifact | Description |
|---|---|
| Source code files | Production code per design/implementation.md |
| Test files | Tests per D4 testing approach |
| tasks.md (update) | Checkboxes marked complete |

### Incremental Mode
- Read from: `{SPECS_DIR}/{feature}/units/{unit}/tasks.md`, `units/{unit}/design/*`
- Update: `units/{unit}/tasks.md` (checkboxes)
- Audit at: `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md` (full) + feature audit (summary)

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve tasks (manifest → conventional path → ask) and design documents
5. Read `{STEERING_DIR}/resources.md` if exists. Read steering Summary sections.
6. **Incremental mode**: read from unit-scoped paths

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Select implementation mode | `{SKILL_DIR}/actions/select-mode.md` |
| 2 | Execute tasks (standard) | `{SKILL_DIR}/actions/standard-mode.md` |
| 2 | Execute tasks (parallel) | `{SKILL_DIR}/references/parallel-mode.md` |
| 2 | Execute tasks (autonomous) | `{SKILL_DIR}/references/autonomous-mode.md` |
| 3 | Finalize implementation | `{SKILL_DIR}/actions/finalize.md` |
| — | Resolve conflicts (if needed) | `{SKILL_DIR}/actions/resolve-conflict.md` |

---

## Phase-Specific Rules

- For incremental mode: write full audit entry to unit audit, one-line summary to feature audit.
- **Audit actions**: mode-selection, task-complete, wave-complete, implementation-complete.

### Implementation Rules
- Follow design documents precisely
- One task at a time — complete fully before moving on (standard mode)
- All tests must pass before marking a task complete
- Do not start a task until its dependencies are complete
- In parallel mode, ONLY create/modify files within assigned ownership paths
- For upstream artifacts, read ONLY `## Summary` section first

### Tool Extensions (beyond shared base)
- **Kiro**: also uses `invokeSubAgent`, `taskStatus`
- **Claude Code**: also uses `Agent`, `TaskUpdate`
- **Cursor/Windsurf**: no sub-agents (parallel/autonomous unavailable)

### User Approval
- Approval signals: "next", "go", "proceed", "yes", "continue", "ok", "done", "approved"
- Changes requested: apply → re-run tests → present updated results → repeat

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `implementation.currentTask` (or `units[{unit}].implementation.currentTask`):
  - `null` + no `implementationMode` → load `actions/select-mode.md`
  - Has `currentTask` → load the mode-specific action file, resume from that task
  - All tasks complete → load `actions/finalize.md`
