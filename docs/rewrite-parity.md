# Rewrite Scope — Functional Parity Rebuilds

For rebuilding an existing system on a modern stack while preserving its behavior — e.g., mainframe/AS400 (RPG, COBOL/400, DDS) to a TypeScript web application. The goal is the same functionality with new technology, so the workflow inverts its usual direction: instead of inventing requirements and designs, it **extracts a baseline from the legacy source and holds every downstream phase accountable to it**.

## When It Activates

Scope detection sets `rewrite` when you describe rebuilding an existing system ("rewrite", "replatform", "modernize", "migrate off", or a legacy stack named) and the legacy code is in the workspace. You can also set it manually: `scope rewrite`.

If the legacy source is not available, the workflow falls back to scope `new` with an explicit warning — parity cannot be extracted or verified without the source.

## The Flow

```
Context → Reverse-Engineer (MANDATORY) → Requirements → [Decomposition] → Design → Tasks → Implement → Build → Deploy
              │ parity baseline                │ parity mode              │ parity rule            │ parity matrix
```

Routing **blocks** requirements until extraction is complete and the baseline is approved. Asking for a later phase early gets a refusal with the extraction status.

## The Parity Baseline

Reverse-engineer produces machine-checkable inventories at `.aidlc/reverse-engineer/parity/`, alongside its 13 analysis documents:

| Inventory | Contents |
|---|---|
| `entities.md` | Every table/file with its FULL field list (type, length, nullable) and per-entity field counts |
| `screens.md` | Every screen/display with its full field list, function keys, and navigation edges |
| `rules.md` | Business-rule register — `BR-{module}-{NNN}` IDs, testable statements, source `file:line` |
| `endpoints.md` | Operation register — `OP-*` IDs for every externally invocable operation |

Counts are **mechanically verified**: schema and screen definitions (SQL DDL, ORM models, DDS members, copybooks) are parsed by generated scripts, not transcribed by eye, and Phase 3 re-runs the scripts to diff counts before presenting. You sign off the baseline explicitly ("approve baseline") — that approval is the parity contract, and the right moment for SME spot-checks.

## How Downstream Phases Are Bound

- **Requirements (parity mode)**: D1 asks parity boundaries (preserve exactly / modernize / drop — per feature area, UX, data). Stories are derived FROM the baseline; every story cites `Legacy-Ref` IDs; every BR-* is restated as EARS acceptance criteria. Generation FAILs on uncovered baseline items.
- **Deviation register** (`deviations.md`): anything NEW, DROPPED, or CHANGED relative to the baseline is a register entry needing approval — never a silent omission. All phases append to it; approvals cover it explicitly.
- **Design (parity rule)**: the data model is a derivation — a legacy→modern type-mapping table (e.g., `PACKED(7,2)` → `DECIMAL(7,2)`), every field mapped or deviation-cited, per-entity counts reconciled (legacy − DROPPED + NEW = modern). Screens map to components/routes, operations to endpoints.
- **Build (parity matrix)**: the implemented schema is parsed mechanically and reconciled against the baseline; screens and rules are traced through to completed tasks. The build report carries the matrix: total / implemented / approved deviations / unaccounted.

## Honest Limits

- Rules that live only in **production data, job schedules, or operator knowledge** are not in the source — they cannot be extracted. The baseline sign-off and deviation approvals are SME checkpoints, not ceremony; use them.
- Where the legacy system still runs, add **characterization tests** (golden input/output pairs for key transactions) to the testing strategy — they catch what extraction missed.
- For IBM i / AS400 codebases, extraction uses `analysis-patterns-rpg-as400.md` (RPG, COBOL/400, CL, DDS — including schema-embedded validation keywords and indicator logic). Complementary extraction tooling (e.g., AWS Transform for mainframe modernization) can feed the same inventories.
