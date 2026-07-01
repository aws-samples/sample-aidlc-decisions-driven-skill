---
name: aidlc-code-review
description: Review implemented code against design specs, coding standards, and best practices. Produces severity-classified findings with suggested fixes.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: code-review, quality, security, testing, compliance, standards, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Code Review Skill

> **Base**: `shared/base.md` (full on first load, §Summary on chain). **Actions**: load per-step from `actions/`.

You review implemented code with a critical eye. Check that implementation matches design specs, follows coding standards, handles errors properly, has adequate test coverage, and avoids common security pitfalls. Be thorough but pragmatic — flag what matters, not what's pedantic.

When active:
1. Follow ONLY the process below
2. Be specific — cite file paths, line ranges, and code snippets
3. ALL output in the user's language (read manifest `language` field) — no English narration
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-code-review v1.0.0 active — {platform} detected.
Ready to review code against design specs and best practices.
```

---

## Quick Start

1. Determine scope: full / scoped / diff / task-specific
2. Read source code + optional design docs, foundation unit design, tasks
3. Check: design compliance, correctness, security, error handling, performance, test quality, code quality
4. Classify findings (🔴 Critical, 🟡 Major, 🟢 Minor, 💡 Suggestion)
5. Generate report → offer to apply fixes

**Reads**: Source code, optionally: design docs, foundation unit design, tasks.md, git diff
**Writes**: code-review.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Source code | Files to review | Any source files in the workspace |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Design documents | Architecture and implementation specs | Markdown (design.md + design/*), OpenAPI |
| Tasks | Task list to verify coverage | Markdown (tasks.md) |
| Foundation unit design | Shared coding standards | Markdown at `{SPECS_DIR}/{feature}/units/foundation/design/*` |
| Git diff | Changes to review | Git diff output, PR diff |

### Outputs
| Artifact | Default Path |
|---|---|
| code-review.md | `{WORKFLOW_DIR}/{feature}/code-review.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest if it exists
4. Determine review scope:
   - **Full**: scan all source files from design/implementation.md
   - **Scoped**: user-specified paths
   - **Diff**: changed files only (git diff)
   - **Task**: files from specific task
5. Resolve optional inputs from manifest or conventional paths

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Review code and generate report | `{SKILL_DIR}/actions/review.md` |
| 2 | Apply fixes (if user requests) | `{SKILL_DIR}/actions/apply-fixes.md` |

---

## Standalone Usage (Outside AIDLC Workflow)

Works without manifest or workflow. Without design docs, reviews against general best practices only.

---

## Phase-Specific Rules

### Review Principles
- Be specific — cite exact files, line numbers, and code snippets
- Be actionable — every finding has a suggested fix
- Be proportional — don't flag 50 minor issues when there are 3 critical bugs
- Be honest — if code is good, say so
- Prioritize: security > correctness > design compliance > performance > test coverage > code quality > style

### Error Recovery
- **No source files found**: Report and ask for correct paths
- **Design docs not found**: Review against general best practices only
- **Large codebase**: Prioritize critical paths, report partial coverage

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check if `{WORKFLOW_DIR}/{feature}/code-review.md` exists:
  - Not present → load `actions/review.md` (start review)
  - Exists → re-read report, present results summary, offer fix/done options
