# Components — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/components.md`

## Structure

```yaml
sections:
  overview: architecture description, interaction summary
  components: # per component
    - purpose, technology, responsibilities
    - exposes: methods/endpoints/events
    - consumes: dependencies
    - internal_structure: directory tree
    - key_decisions: numbered with rationale
    - error_handling
  interactions:
    - ascii_diagram: component relationships
    - data_flow: how data moves through components
```

## Rules
- One component per bounded responsibility (not per file)
- Every user story maps to at least one component
- Exposes/Consumes creates a dependency graph — verify no cycles
- Internal structure uses conventions from foundation.md or D3 architecture pattern
