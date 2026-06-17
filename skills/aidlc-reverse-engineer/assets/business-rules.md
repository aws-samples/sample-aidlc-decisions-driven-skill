# Business Rules — Output Template

**Path**: `{OUTPUT_DIR}/business-rules.md`

~~~markdown
<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->
# Business Rules

## Summary

[detected] business rules across [count] domains. [Brief characterization of rule density and complexity.]

## Rules by Domain

### [Domain Name]

| Rule | Type | Description | Location | Trigger |
|---|---|---|---|---|
| [name] | [validation/state-machine/calculation/authorization/invariant] | [description] | [file:function] | [event or condition] |

## State Machines

### [Machine Name]

- **Entity**: [entity]
- **Location**: `[file:function]`

#### States & Transitions

| From | Event | To | Guard |
|---|---|---|---|
| [state] | [event] | [state] | [condition] |

```
[ASCII state diagram]

  ┌─────────┐  approve   ┌──────────┐
  │  draft   │──────────▶│ approved │
  └────┬────┘            └────┬─────┘
       │ reject               │ ship
       ▼                      ▼
  ┌─────────┐            ┌──────────┐
  │ rejected │            │ shipped  │
  └─────────┘            └──────────┘
```
~~~
