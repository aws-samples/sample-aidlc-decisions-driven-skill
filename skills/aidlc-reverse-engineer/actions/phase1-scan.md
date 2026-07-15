# Phase 1: Scan & Map

A lightweight pass that reads only structure — no deep file reading.

## Step 1: Project Detection
- Identify language(s), frameworks, build tools from config files
- Identify architecture pattern from directory structure and imports
- Count source files, test files, config files per module
- Count total lines of code (use `wc -l` or equivalent)
- Read README and any architecture docs
- Detect infrastructure files: Dockerfiles, CI/CD configs, IaC files
- Detect configuration approach: .env files, config directories, secrets references
- Check framework/language versions against known EOL dates

## Step 2: Module Mapping
- Identify top-level modules/packages/directories
- For each module: purpose (inferred from name + exports), file count, line count, test coverage presence
- Map import dependencies between modules (read only index/barrel files and entry points)
- Detect circular dependencies
- Identify entry points (main files, API servers, CLI commands, workers)
- **Flag large modules** (150+ files) for subdivision

## Step 3: Generate
Read `{ASSETS_DIR}/overview.md` template → **write** `{OUTPUT_DIR}/overview.md`
Read `{ASSETS_DIR}/modules.md` template → **write** `{OUTPUT_DIR}/modules.md`

## Step 4: Initialize Output Files
Create each output file with its header and empty summary table:
- `data-model.md`, `api-surface.md`, `business-rules.md`, `features.md`, `integrations.md`, `conventions.md`, `security.md`, `debt.md` — header only
- `infrastructure.md` — generate now (from Dockerfiles, CI configs, IaC files — project-level)
- `configuration.md` — generate env vars section now (from .env files, config files); per-module findings appended later

**Parity mode** (manifest `state.scope` is `rewrite`, or user requested parity inventories):
- Read `{ASSETS_DIR}/parity-inventory.md` → create `{OUTPUT_DIR}/parity/{entities,screens,rules,endpoints}.md` (headers + empty Totals)
- Identify **schema-bearing and screen-bearing sources** during the scan: SQL DDL / migrations, ORM models, DDS physical/logical files, copybooks, DDS display files, form/template definitions. List them in `{WORK_DIR}/parity-sources.json` (path + kind) — Phase 2 parses these mechanically.

## Step 5: Create Progress File
**Write** `{WORK_DIR}/progress.json` with all modules set to `"pending"`.

## Step 6: Determine Module Processing Order
1. Shared/common modules first (utilities, shared types, config)
2. Core domain modules next (ordered by dependency — fewer deps first)
3. Integration/infrastructure modules last

## Present (iterative mode only)

```
📍 Reverse Engineer: Scan & Map Complete

- **Stack**: [detected]
- **Architecture**: [detected pattern]
- **Modules**: [X] identified ([Y] files, [Z] total LOC)
- **Entry Points**: [W] found
- **Processing Order**: [list modules in order]

---
🔲 **Your turn**:
- ✅ "continue" — begin module-by-module analysis
- 🔍 "deep-dive [module]" — analyze a specific module only
- ⏸️ "stop" — enough context for now
```

**Iterative mode: STOP and wait.** Full mode: proceed to Phase 2 immediately.
