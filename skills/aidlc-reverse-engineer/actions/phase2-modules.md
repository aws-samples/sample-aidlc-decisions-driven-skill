# Phase 2: Module-by-Module Analysis

Process each module sequentially. For each module:

## Step 1: Read All Files in the Module

Read ALL source files in the module's directory. No budget — read everything.

If 150+ files, subdivide by subdirectory and process each batch sequentially within the module.

## Step 2: Extract Findings

For the current module, extract ALL of:

- **Data Model**: ORM models, migrations, schemas, entities with full fields/types/relationships/indexes, access patterns, DTOs/mappers
- **API Surface**: Route definitions, controller decorators, handler registrations. Per endpoint: method, path, handler, middleware chain, request/response shapes, auth requirements
- **Business Rules**: Validation rules, state machines, calculations, authorization rules, invariants, conditional flows, scheduled logic. Per rule: what it enforces, file:line, trigger
- **Features**: User-facing capabilities, routes+handlers+services+models working together, completeness (full/partial/stubbed), maturity, user journey steps, TODO/FIXME/HACK comments
- **Integrations**: HTTP clients, SDK imports, queue producers/consumers, cache clients. Per integration: service name, protocol, data flow, error handling, config
- **Conventions**: Naming patterns, error handling, auth mechanism, logging, testing patterns
- **Security**: Unprotected endpoints, input validation gaps, hardcoded secrets, overly broad data exposure, deprecated crypto
- **Configuration**: Environment variables consumed, feature flags checked, config file reads
- **Technical Debt**: Complexity hotspots, dead code, test coverage gaps, inconsistencies with other modules, missing abstractions, deprecated API usage

## Step 3: Write Findings — One File at a Time

**CRITICAL**: Write ONE output file per turn. For each that has findings:

1. `data-model.md` → append under `## Module: {moduleName} (\`{modulePath}\`)`
2. `api-surface.md` → append
3. `business-rules.md` → append
4. `features.md` → append
5. `integrations.md` → append
6. `conventions.md` → append
7. `security.md` → append
8. `configuration.md` → append
9. `debt.md` → append

**Skip files where this module has no findings.**

**If a section exceeds ~150 lines**, split into sub-sections and write each separately.

## Step 4: Update Progress

Update `{WORK_DIR}/progress.json` — set module status to `"done"` with timestamp and file count.

## Step 5: Release Context

Module source code no longer needed. Proceed to next module.

---

## Iterative Mode Presentation (after each module)

```
📍 Module Complete: {moduleName} ({fileCount} files)

- **Entities**: [X], **Endpoints**: [Y], **Business Rules**: [Z]
- **Integrations**: [W], **Debt Signals**: [V]

Progress: {completed}/{total} modules

---
🔲 **Your turn**:
- ✅ "continue" — proceed to next module
- ⏸️ "stop" — pause here (progress saved)
```

---

## Parallel Execution (Kiro/Claude Code Only)

On platforms with sub-agents, Phase 2 can be parallelized:

| Condition | Strategy |
|---|---|
| ≤5 modules | Sequential |
| 6+ modules | Parallel — one sub-agent per module (or per group if >8) |

**Parallel steps**:
1. Complete Phase 1 directly
2. Group modules (keep 3-8 sub-agents). Dispatch ALL in same response.
3. Each sub-agent writes to `{WORK_DIR}/modules/{moduleName}-{aspect}.md`
4. After all complete, merge results sequentially (one aspect at a time, one module file at a time)
5. Proceed to Phase 3

Sub-agent prompt must include: module name/path/purpose/dependencies, all 9 extraction aspects, output file paths in `{WORK_DIR}/modules/`, language reference path, and rules (read ALL files, write ONE file at a time, cite file:line).
