# System Overview — Output Template

**Path**: `{OUTPUT_DIR}/overview.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: 10-line narrative digest (what, who, how, architecture, state)
  stack: table with layer, technology, version, EOL status
  architecture_pattern:
    - pattern_name: detected
    - ascii_diagram: high-level architecture
  system_context:
    - ascii_diagram: external systems and this system's boundaries
    - external_dependencies: table (system, direction, protocol, purpose)
    - external_consumers: table (consumer, protocol, what they access)
  entry_points: table (entry, type, file, description)
  project_statistics: table (metric, value) — LOC, files, tests, ratio, deps, modules, endpoints, entities, integrations
  migration_readiness:
    - version_eol_risk: table (component, current, latest, gap, risk)
    - modernization_signals: table (signal, status, details) — framework, deprecated APIs, vendor lock-in, stateful components, decomposition readiness, data migration complexity, test coverage
    - recommended_priorities: table (priority, area, rationale, effort, impact)
```

## Rules
- All counts must come from actual file scanning, not estimates
- EOL status checked against known dates for the detected versions
- ASCII diagrams must reflect the actual detected architecture, not generic examples
