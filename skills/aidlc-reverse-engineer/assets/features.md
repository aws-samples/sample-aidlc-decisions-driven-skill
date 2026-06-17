# Features — Output Template

**Path**: `{OUTPUT_DIR}/features.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: count complete/partial/stubbed, brief characterization
  feature_inventory: table (name, status, maturity, modules, routes, entities)
  feature_details: # per feature
    per_feature:
      - status: complete/partial/stubbed
      - maturity: MVP/stable/mature/deprecated
      - description: user perspective
      - capabilities: bullet list
      - implementing_code: table (component, file:line, function/class)
      - dependencies: requires + required_by
  user_journeys: # per journey
    per_journey:
      - actor, goal
      - steps: table (step, action, feature, endpoint/UI, module)
      - ascii_flow: for complex journeys
  feature_dependencies: ASCII dependency graph
  missing_incomplete: table (feature, evidence, status, notes with file:line)
```

## Rules
- Every route handler maps to a feature
- Status determined from code completeness (stubs, TODOs, empty handlers = partial/stubbed)
- Journeys compiled from per-module analysis during cross-cutting phase
