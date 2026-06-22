# Scopes — Single Source of Truth

> **Usage**: This file defines all workflow scopes and their phase mappings. Referenced by routing, context assessment, base rules, and the orchestrator. Load this file when making scope-based decisions — do not duplicate these tables elsewhere.

---

## Available Scopes

| Scope | Description | Best For |
|---|---|---|
| `new` | Full workflow, all phases | New projects, rewrites, building from scratch |
| `feature` | Full workflow, all phases | Adding new capability to existing code |
| `bugfix` | Streamlined — skips decomposition, deploy | Fixing specific bugs or errors |
| `refactor` | Streamlined — skips requirements, decomposition, deploy | Restructuring code without changing behavior |

---

## Phase Mapping

### Active Phases per Scope

| Scope | Active Phases |
|---|---|
| `new` | context → requirements → decomposition → design → tasks → implement → build → deploy |
| `feature` | context → requirements → decomposition → design → tasks → implement → build → deploy |
| `bugfix` | context → requirements → design → tasks → implement → build |
| `refactor` | context → design → tasks → implement → build |

### Phases Skipped per Scope

| Scope | Skipped Phases | Rationale |
|---|---|---|
| `new` | — | Full workflow, all phases relevant |
| `feature` | — | Full workflow, all phases relevant |
| `bugfix` | decomposition, deploy | Narrow scope, fix-and-verify pattern |
| `refactor` | requirements, decomposition, deploy | Code structure change, no new behavior |

---

## Decision Gate Behavior per Scope

| Scope | Active Decision Gates | Notes |
|---|---|---|
| `new` | D1, D2, D3, D4, D5 | All gates active |
| `feature` | D1, D2, D3, D4, D5 | All gates active |
| `bugfix` | D3, D4 | Skip D1 — use lightweight requirements (fewer questions, focused on the fix) |
| `refactor` | D3, D4 | Skip D1 and D2 — no business requirements or decomposition |

---

## Detection Rules

Used during context assessment (Step 5) to auto-detect scope:

| Scope | Detect When | Keywords / Signals |
|---|---|---|
| `new` | No existing source code, OR user describes building from scratch, OR rewriting | "build from scratch", "new project", "create a new", "rewrite", "rebuild", "start over", greenfield workspace |
| `bugfix` | User describes fixing a specific bug or error | "fix", "bug", "error", "broken", "not working", "regression", "patch", specific error messages |
| `refactor` | User describes restructuring without changing behavior | "refactor", "restructure", "clean up", "reorganize", "migrate to", "upgrade", "rename", "extract" |
| `feature` | Everything else — adding new capability to existing code | "add", "implement", "build", "create" (in brownfield context), new endpoint/page/service |

**Ambiguity rule**: If detection is ambiguous (e.g., "fix and improve the auth system"), default to `feature` and let the user override.

**Rewrite detection**: If the user says "rewrite" or "rebuild" and an existing codebase exists (brownfield workspace), set scope to `new` and recommend running `reverse-engineer` first.

---

## Workflow Diagram Templates per Scope

Used when presenting context assessment results:

- **new/feature — Simple** (Units=No): Context → Requirements → Design → Tasks → Implement → Build and Test → Deploy
- **new/feature — Complex** (Units=Yes): Context → Requirements → Decomposition → [Unit cycles: Design → Tasks → Implement] → Build and Test → Deploy
- **bugfix**: Context → Requirements (lightweight) → Design → Tasks → Implement → Build and Test
- **refactor**: Context → Design → Tasks → Implement → Build and Test
- **With prototype** (any scope): Context → Requirements ↔ Prototype → then continue normal path

---

## Scope Change Rules

- User can change scope at any time via `scope [name]` command
- Changing to a narrower scope: completed phases that are now "skipped" are preserved but become irrelevant
- Changing to a wider scope: additional phases become active and need to be completed
- Scope is stored in manifest at `state.scope` and `context-summary.scope`
