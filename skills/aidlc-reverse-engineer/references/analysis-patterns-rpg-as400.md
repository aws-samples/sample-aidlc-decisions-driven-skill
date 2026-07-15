# Analysis Patterns: RPG / COBOL/400 / CL (IBM i / AS400)

**Source members**: `*.RPGLE`/`*.SQLRPGLE` (RPG IV/ILE, fixed or **FREE), `*.RPG` (RPG III), `*.CBLLE`/`*.CBL` (COBOL/400), `*.CLLE`/`*.CLP` (CL), `*.DSPF`/`*.PF`/`*.LF`/`*.PRTF` (DDS), `QDDSSRC`/`QRPGLESRC`/`QCLSRC` source physical files, `/COPY` + `/INCLUDE` copybooks
**Entry points**: `*ENTRY PLIST` / `main()` (RPG), `PGM` (CL), CL programs that call RPG (`CALL PGM(...)`), job scheduler entries (`WRKJOBSCDE` exports), trigger programs (`ADDPFTRG`), menu definitions
**Environment**: DB2 for i (physical/logical files or SQL DDL), data areas (`*DTAARA`), data queues (`*DTAQ`), message files (`MSGF` — user-facing text + error messages), spooled-file reports (PRTF), 5250 display files (DSPF)

## Where parity-critical facts live (map to parity inventories)

| Legacy artifact | Parity inventory | What to extract |
|---|---|---|
| DDS PF/LF members, SQL DDL | `parity/entities.md` | EVERY field: name, type (A/P/S/B/Z…), length/decimals, keys, `VALUES`/`RANGE`/`COMP`/`CHECK` keywords (validation rules IN the schema — also emit as BR-*), LF select/omit (business filters) |
| DDS DSPF members | `parity/screens.md` | EVERY field with usage (I/O/B/H), length, `EDTCDE`/`EDTWRD` (display formatting), `VALUES`/`RANGE` (input validation → BR-*), `CA*`/`CF*` function keys, indicator-conditioned fields (conditional UI), record formats = screen states |
| RPG/COBOL logic | `parity/rules.md` | Calculations (`EVAL`, `COMPUTE`), `IF`/`SELECT`/`WHEN` chains on status fields, `CHAIN`/`SETLL`/`READE` access patterns (existence/duplicate checks), indicator logic (`*INxx`, `SETON`/`SETOFF`), `88-level` conditions (COBOL), subroutines/procedures with business names (`EXSR`, `CALLP`) |
| CL programs, job schedule, trigger programs | `parity/rules.md` (scheduling/side-effect) + `integrations.md` | Batch flows, `SBMJOB` chains, `OVRDBF` redirections, trigger-attached logic |
| PRTF members + O-specs | `parity/screens.md` (as report layouts) | Report fields, totals/level breaks (`L1`–`L9` — aggregation rules → BR-*) |

## Business Rule Extraction Heuristics

| Signal | What It Indicates |
|---|---|
| DDS `VALUES`/`RANGE`/`COMP`/`CHECK` keywords | Field-level validation rules (schema-embedded — easy to lose in rewrite) |
| `*INxx` indicator set/tested across operations | Workflow state or error signaling — trace set→test pairs |
| `CHAIN` then `%FOUND`/`NOT %FOUND` branch | Existence/uniqueness rule |
| `EVAL`/`COMPUTE` with business-named targets | Business calculation (capture the exact expression + rounding: `H`-spec `EXPROPTS`, `EVAL(H)`) |
| `SELECT`/`WHEN` or `EVALUATE` on status fields | State machine |
| Level-break logic (`L1`–`L9`) in reports | Aggregation/subtotal business rules |
| `MSGF` message IDs sent on conditions | User-facing validation text (preserve wording for UX parity) |
| Data-area reads at program start | Business parameters/configuration (rates, next-number counters) |
| Trigger programs (`ADDPFTRG`) | Rules that fire on data change — invisible in call graphs |
| LF select/omit criteria | Business filters baked into "views" |

## Cautions

- Fixed-format RPG columns are positional — when parsing mechanically, split by column positions, not whitespace.
- Packed/zoned decimal (`P`/`S`) lengths are digits, not bytes — map `PACKED(7,2)` → `DECIMAL(7,2)`, never `FLOAT`.
- Indicators and `GOTO`-heavy RPG III hide rules in control flow — trace each indicator's set/test pairs before declaring a rule inventory complete.
- Field reference files (a PF referenced via `REF`/`REFFLD`) centralize definitions — resolve references before counting fields.

## Test patterns

Rarely present. RPGUnit / iUnit if any; otherwise note `[no automated tests — characterization tests recommended]` in debt.md and flag for the rewrite's testing strategy.
