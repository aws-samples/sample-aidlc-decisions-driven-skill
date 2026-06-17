# Module Inventory — Output Template

**Path**: `{OUTPUT_DIR}/modules.md`

~~~markdown
<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->
# Module Inventory

## Summary

[detected] modules identified. [Brief characterization of modularity, coupling, and cohesion.]

## Modules

| Module | Purpose | Files | Lines of Code | Test Coverage | Dependencies |
|---|---|---|---|---|---|
| [name] | [purpose] | [count] | [count] | [%] | [list] |

## Dependency Graph

```
[ASCII dependency graph]

  auth ──▶ users
    │        │
    ▼        ▼
  database ◀── orders
    │
    ▼
  config
```

## Circular Dependencies

| Cycle | Modules | Severity |
|---|---|---|
| [id] | [module-a] ↔ [module-b] | [high/medium/low] |

<!-- If none detected: "No circular dependencies detected." -->

## Module Details

### [Module Name]

- **Path**: `[directory]`
- **Exports**: [list of public interfaces]
- **Imports**: [list of consumed modules]
- **Responsibilities**: [bullet list of what this module owns]
~~~
