# Conventions — Output Template

**Path**: `{OUTPUT_DIR}/conventions.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: consistency characterization, detected patterns, notable deviations
  naming_conventions: table (element, convention, example, consistency high/medium/low)
    elements: files, functions, classes, variables, DB tables, routes
  error_handling:
    - pattern, location file:line, custom errors (yes/no + list), consistency
  auth_pattern:
    - pattern, location, applied_via (middleware/decorator/manual), consistency
  logging_pattern:
    - library, format, levels used, consistency
  testing_pattern:
    - framework, style, location, mocking approach, consistency
  code_organization:
    - pattern: feature-based/layer-based/hybrid
    - directory_layout: detected snippet
```

## Rules
- Every convention must cite where it was detected (file:line or pattern source)
- Consistency rated from actual variance across modules, not assumption
- Cross-cutting analysis adds: universal vs module-specific, inconsistencies, dominant vs outlier
