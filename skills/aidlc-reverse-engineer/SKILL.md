---
name: aidlc-reverse-engineer
description: Deep brownfield codebase analysis. Extracts architecture, modules, data models, API surface, business rules, features, integrations, conventions, and technical debt.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.1.0
  author: AI-DLC Maintainers
  keywords: reverse-engineer, brownfield, codebase-analysis, architecture, business-rules, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Reverse Engineer Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each phase — do not load all phases upfront.

You perform deep analysis of existing codebases. Extract architecture, module boundaries, data models, API contracts, business rules, features, integrations, conventions, and technical debt.

When active:
1. Follow ONLY the process below
2. WAIT for user confirmation after each pass (iterative mode)
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration
4. Process modules sequentially — analyze one module fully, write results, then move to the next

---

## Activation

```
✅ aidlc-reverse-engineer v1.1.0 active — {platform} detected.
Ready to analyze your codebase. Provide a scope or say "full project".
```

---

## Quick Start

1. User provides scope (directory, module, or "full project" — default)
2. **Phase 1: Scan & Map** — lightweight: directory structure, configs, entry points
3. **Phase 2: Module-by-module** — read ALL files per module, extract findings, write, move on
4. **Phase 3: Cross-cutting** — read only output files, add cross-module observations
5. User can deep-dive or update after completion

**Reads**: Source code, configs, tests, migrations, README, Dockerfiles, CI/CD, IaC
**Writes**: `.aidlc/reverse-engineer/` (13 analysis documents)

---

## Core Approach

The context limit applies per-module, not per-project. Process one module at a time:
- Read ALL files in one module → extract findings → write to output → release context → next module
- Large modules (150+ files): subdivide by subdirectory, process each batch sequentially

---

## Environment Paths (extends shared base)

- `OUTPUT_DIR` = `.aidlc/reverse-engineer`
- `WORK_DIR` = `{OUTPUT_DIR}/_work`

Output structure:
```
.aidlc/reverse-engineer/
├── _work/                    ← intermediate (deleted on completion)
│   ├── progress.json
│   └── modules/
├── README.md, overview.md, modules.md
├── data-model.md, api-surface.md, business-rules.md, features.md
├── integrations.md, conventions.md, infrastructure.md
├── security.md, configuration.md, debt.md
```

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Source code | Codebase to analyze | Filesystem access |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Scope | Directory or "full project" | Path or keyword |
| Existing analysis | Previous output to update | Files in `.aidlc/reverse-engineer/` |

### Outputs

| Artifact | Path | Produced By |
|---|---|---|
| README.md | `{OUTPUT_DIR}/README.md` | Phase 3 |
| overview.md | `{OUTPUT_DIR}/overview.md` | Phase 1 |
| modules.md | `{OUTPUT_DIR}/modules.md` | Phase 1 |
| data-model.md | `{OUTPUT_DIR}/data-model.md` | Phase 2 + Phase 3 |
| api-surface.md | `{OUTPUT_DIR}/api-surface.md` | Phase 2 + Phase 3 |
| business-rules.md | `{OUTPUT_DIR}/business-rules.md` | Phase 2 + Phase 3 |
| features.md | `{OUTPUT_DIR}/features.md` | Phase 2 + Phase 3 |
| integrations.md | `{OUTPUT_DIR}/integrations.md` | Phase 2 + Phase 3 |
| conventions.md | `{OUTPUT_DIR}/conventions.md` | Phase 2 + Phase 3 |
| infrastructure.md | `{OUTPUT_DIR}/infrastructure.md` | Phase 1 + Phase 3 |
| security.md | `{OUTPUT_DIR}/security.md` | Phase 2 + Phase 3 |
| configuration.md | `{OUTPUT_DIR}/configuration.md` | Phase 1 + Phase 2 + Phase 3 |
| debt.md | `{OUTPUT_DIR}/debt.md` | Phase 2 + Phase 3 |

---

## Initialization

1. Detect environment
2. Create `{OUTPUT_DIR}/` and `{WORK_DIR}/modules/` if needed
3. Check for existing analysis (`overview.md` exists → offer update/extend)
4. Check for `{WORK_DIR}/progress.json` → resume from next incomplete module
5. Resolve scope from user (default: full project)
6. Resolve mode: **full** (default, no stops) or **iterative** (stop after each module)

---

## Process

Execute phases sequentially. **Load the action file when you reach that phase — not before.**

| Phase | Action | Load |
|---|---|---|
| 1 | Scan & Map (lightweight) | `{SKILL_DIR}/actions/phase1-scan.md` |
| 2 | Module-by-module analysis | `{SKILL_DIR}/actions/phase2-modules.md` |
| 3 | Validation & cross-cutting | `{SKILL_DIR}/actions/phase3-crosscutting.md` |

---

## Skill Handoff

**Next skill**: `aidlc-context` (when user says "start context" or "done, start context").

---

## Phase-Specific Rules

### Analysis Principles
- **Read ALL code in each module.** No budgets, no sampling, no skipping.
- Read code, don't guess. Every claim traceable to file:line.
- Be honest about uncertainty.
- Don't judge — document factually.
- **Write ONE file at a time.** Never multiple output files in a single response.
- **Write after each module.** Never hold multiple modules in context.
- **Large modules (150+ files)**: subdivide by subdirectory.
- **Large sections (150+ lines)**: split into sub-sections, write each separately.
- **Load only the relevant language reference** (`analysis-patterns-{language}.md`).
- **Intermediate files in `{WORK_DIR}/`** — never in `{OUTPUT_DIR}/`.

### Tool Extensions
- **Kiro**: also uses `invokeSubAgent`
- **Claude Code**: also uses `Agent`

### Recovery
- Read `{WORK_DIR}/progress.json` → resume from next incomplete module.

### Timestamps
Every generated file includes: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`
