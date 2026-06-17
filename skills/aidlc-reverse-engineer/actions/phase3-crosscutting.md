# Phase 3: Validation & Cross-Cutting Analysis

After ALL modules processed, validate completeness and perform cross-cutting analysis.

## Validation Step

Verify:
1. **Module coverage**: All modules in `modules.md` processed (check `{WORK_DIR}/progress.json`)
2. **Orphaned files**: Source files not belonging to any module → report in `overview.md` under `## Unassigned Files`
3. **Consistency check**: Aggregate counts match per-module sums

Report gaps but continue with cross-cutting analysis.

## Cross-Cutting Analysis

Read ONLY the generated output files (not source code). Append `## Cross-Cutting Analysis` section to each:

- **data-model.md**: Cross-module relationships, shared entities, data consistency concerns, cross-module ER diagram
- **api-surface.md**: API consistency (naming, response formats, error shapes), shared middleware, versioning, endpoint counts by module
- **business-rules.md**: Rules spanning multiple modules, conflicting rules, implicit dependencies
- **features.md**: Cross-module features, boundary alignment, user journeys crossing modules, feature dependency graph
- **conventions.md**: Universal vs module-specific conventions, inconsistencies, dominant patterns vs outliers
- **security.md**: System-wide auth coverage (% protected), cross-module patterns/gaps, aggregate vulnerability count, overall posture rating
- **configuration.md**: Complete env var inventory (deduplicated), consistency, missing/undocumented variables
- **debt.md**: Risk heatmap (module × dimensions), system-level debt (circular deps, duplicated logic), architectural debt, aggregate metrics, remediation priorities
- **overview.md**: System context diagram (from integrations), migration readiness assessment, recommended modernization priorities

After cross-cutting analysis, update summary tables at the top of each output file with aggregate counts.

## Generate Report README

Read `{ASSETS_DIR}/report-readme.md` → **write** `{OUTPUT_DIR}/README.md`

## Cleanup

Delete the entire `{WORK_DIR}/` directory (removes progress.json and intermediate files).

## Present

```
📍 Reverse Engineer: Analysis Complete

13 documents generated at `.aidlc/reverse-engineer/`:

📋 Navigation & Overview: README.md, overview.md, modules.md
📊 Technical Analysis: data-model.md, api-surface.md, business-rules.md, features.md
🔌 Operations & Integration: integrations.md, infrastructure.md, configuration.md
🛡️ Quality & Risk: conventions.md, security.md, debt.md

---
🔲 **Your turn**:
- 🔍 "deep-dive [area]" — drill deeper into any area
- 🔄 "update [module]" — refresh a specific module's analysis
- ✅ "done" — analysis complete
- 👉 "start context" — proceed to aidlc-context
```

**STOP and wait.**

---

# Action: deep-dive

When user says "deep-dive [target]":
1. Identify target (module, directory, feature area, or domain)
2. Read ALL source files in that scope (no budget)
3. Update relevant analysis documents with deeper detail
4. Present findings and updated file list

---

# Action: update

When user says "update" or "update [target]":
1. Specific file → re-analyze relevant modules, regenerate with fresh timestamp
2. Specific module → re-run module analysis, update all output files
3. No target → re-run full analysis
4. Preserve structure, refresh content
5. Note what changed vs previous analysis

---

# Scoped Analysis

When analyzing a specific directory (not full project):
- Output files still written to `{OUTPUT_DIR}/` (project-scoped)
- Each file includes "Scope" header noting what was analyzed
- Subsequent scoped analyses **merge** into existing files
- Use section headers: `## Module: payments (src/payments/)`
