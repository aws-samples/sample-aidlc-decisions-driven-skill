# Scopes — Single Source of Truth

> **Usage**: This file defines all workflow scopes and their phase mappings. Referenced by routing, context assessment, base rules, and the orchestrator. Load this file when making scope-based decisions — do not duplicate these tables elsewhere.

---

## Available Scopes

| Scope | Description | Best For |
|---|---|---|
| `new` | Full workflow, all phases | New projects, building from scratch (for parity rebuilds of existing systems use `rewrite`) |
| `feature` | Full workflow, all phases | Adding new capability to existing code |
| `bugfix` | Streamlined — skips decomposition, deploy | Fixing specific bugs or errors |
| `refactor` | Streamlined — skips requirements, decomposition, deploy | Restructuring code without changing behavior |
| `rewrite` | Full workflow + mandatory legacy extraction | Rebuilding an existing system on a modern stack with functional parity (e.g., mainframe/AS400 → web) |

---

## Phase Mapping

### Active Phases per Scope

| Scope | Active Phases |
|---|---|
| `new` | context → requirements → decomposition → design → tasks → implement → build → deploy |
| `feature` | context → requirements → decomposition → design → tasks → implement → build → deploy |
| `bugfix` | context → requirements → design → tasks → implement → build |
| `refactor` | context → design → tasks → implement → build |
| `rewrite` | context → **reverse-engineer** → requirements → decomposition → design → tasks → implement → build → deploy |

### Phases Skipped per Scope

| Scope | Skipped Phases | Rationale |
|---|---|---|
| `new` | — | Full workflow, all phases relevant |
| `feature` | — | Full workflow, all phases relevant |
| `bugfix` | decomposition, deploy | Narrow scope, fix-and-verify pattern |
| `refactor` | requirements, decomposition, deploy | Code structure change, no new behavior |
| `rewrite` | — | Full workflow; `reverse-engineer` is MANDATORY (parity baseline), never optional |

---

## Decision Gate Behavior per Scope

| Scope | Active Decision Gates | Notes |
|---|---|---|
| `new` | D1, D2, D3, D4, D5 | All gates active |
| `feature` | D1, D2, D3, D4, D5 | All gates active |
| `bugfix` | D3, D4 | Skip D1 — use lightweight requirements (fewer questions, focused on the fix) |
| `refactor` | D3, D4 | Skip D1 and D2 — no business requirements or decomposition |
| `rewrite` | D1, D2, D3, D4, D5 | All gates active. D1 runs in **parity mode** — questions cover what to preserve / modernize / drop against the extracted baseline, not product invention |

---

## Detection Rules

Used during context assessment (Step 5) to auto-detect scope:

| Scope | Detect When | Keywords / Signals |
|---|---|---|
| `new` | No existing source code, OR user describes building from scratch | "build from scratch", "new project", "create a new", "start over", greenfield workspace |
| `rewrite` | User describes rebuilding/replacing an existing system while keeping its behavior, AND the legacy codebase exists in the workspace | "rewrite", "rebuild", "replatform", "modernize", "migrate off", "port to", legacy stack named (mainframe, AS400, COBOL, VB6, ...) |
| `bugfix` | User describes fixing a specific bug or error | "fix", "bug", "error", "broken", "not working", "regression", "patch", specific error messages |
| `refactor` | User describes restructuring without changing behavior | "refactor", "restructure", "clean up", "reorganize", "migrate to", "upgrade", "rename", "extract" |
| `feature` | Everything else — adding new capability to existing code | "add", "implement", "build", "create" (in brownfield context), new endpoint/page/service |

**Ambiguity rule**: If detection is ambiguous (e.g., "fix and improve the auth system"), default to `feature` and let the user override.

**Rewrite detection**: If the user describes rebuilding an existing system and the legacy codebase exists in the workspace, set scope to `rewrite`. In this scope `reverse-engineer` is a mandatory phase between context and requirements — routing blocks requirements until extraction is complete and approved, and the extracted inventories become the parity baseline downstream phases must trace to. If the legacy source is NOT available in the workspace, ask for its location; if it cannot be provided, fall back to scope `new` with a ⚠️ warning that functional parity cannot be extracted or verified.

---

## Workflow Diagram Templates per Scope

Used when presenting context assessment results:

- **new/feature — Simple** (Units=No): Context → Requirements → Design → Tasks → Implement → Build and Test → Deploy
- **new/feature — Complex** (Units=Yes): Context → Requirements → Decomposition → [Unit cycles: Design → Tasks → Implement] → Build and Test → Deploy
- **bugfix**: Context → Requirements (lightweight) → Design → Tasks → Implement → Build and Test
- **refactor**: Context → Design → Tasks → Implement → Build and Test
- **rewrite**: Context → Reverse-Engineer (parity baseline) → Requirements → [Decomposition → Unit cycles OR Design → Tasks → Implement] → Build and Test (parity check) → Deploy
- **With prototype** (any scope): Context → Requirements ↔ Prototype → then continue normal path

---

## Scope Change Rules

- User can change scope at any time via `scope [name]` command
- Changing to `rewrite`: the `reverse-engineer` phase becomes required — routing dispatches it before requirements if extraction hasn't run yet
- Changing to a narrower scope: completed phases that are now "skipped" are preserved but become irrelevant
- Changing to a wider scope: additional phases become active and need to be completed
- Scope is stored in manifest at `state.scope` and `context-summary.scope`
