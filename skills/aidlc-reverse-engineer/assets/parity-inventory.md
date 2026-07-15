# Parity Inventory — Output Templates

Machine-checkable baselines for functional-parity rewrites. Written to `{OUTPUT_DIR}/parity/` (four files).

**Generate when**: manifest `state.scope` is `rewrite`, OR the user explicitly asks for parity inventories.

**Contract**: downstream phases (requirements, design, build) trace to these IDs and counts — they are the parity baseline the rebuild is checked against. Precision beats prose: one row per fact, every row cites its legacy source (`file:line` or member/object name). Never summarize a field list; enumerate it. If something cannot be determined from source, write `[UNKNOWN — verify with SME]`, never a guess.

---

## parity/entities.md

```yaml
header: "<!-- Analyzed: {ISO} | Scope: {scope} -->"
per_entity:                    # one section per table / physical file / persistent structure
  heading: "## {ENTITY-ID}: {name} ({legacy source, e.g., DDS member, DDL file, schema.table})"
  meta: purpose (1 line), module, source file:line
  fields_table: |              # EVERY field — no elisions, no "..." rows
    | # | Field | Type | Length/Precision | Nullable | Default | Description |
  field_count: "**Field count**: {N}"   # must equal table row count
  keys: primary key, unique keys, indexes (name + fields)
  relationships: "{entity} → {entity} ({cardinality}, via {fields})"
totals_section: |              # ## Totals — machine-checkable
  | Module | Entities | Fields |
  ...one row per module + **Grand total** row
```

## parity/screens.md

```yaml
header: "<!-- Analyzed: {ISO} | Scope: {scope} -->"
per_screen:                    # one section per screen / display file / form / report layout
  heading: "## {SCR-ID}: {name} ({legacy source, e.g., DSPF member, JSP, form})"
  meta: purpose, calling programs/routes, module
  fields_table: |              # EVERY visible field — input, output, hidden, constants
    | # | Field | Type (I/O/B/H) | Length | Validation/Edit codes | Label |
  field_count: "**Field count**: {N}"
  function_keys: "| Key | Action |"     # F3=Exit, F12=Cancel, Enter=..., or buttons/actions
  navigation: "→ {SCR-ID} on {condition}"   # screen flow edges
totals_section: "| Module | Screens | Fields | — + Grand total"
```

## parity/rules.md

```yaml
header: "<!-- Analyzed: {ISO} | Scope: {scope} -->"
register_table: |              # the BR register — one row per rule, stable IDs
  | ID | Rule (precise, testable statement) | Trigger | Entities/Fields | Source |
  # ID format: BR-{module}-{NNN} (zero-padded, never renumber existing IDs on update)
  # Source: file:line (or member + statement range)
categories: validation, calculation, state-machine, authorization, scheduling, side-effect
totals_section: "| Module | Rules | — + Grand total"
```

## parity/endpoints.md

```yaml
header: "<!-- Analyzed: {ISO} | Scope: {scope} -->"
register_table: |              # every externally invocable operation
  | ID | Operation (path / program / transaction / job) | Protocol | Inputs | Outputs | Auth | Source |
  # ID format: OP-{module}-{NNN}
totals_section: "| Module | Operations | — + Grand total"
```
