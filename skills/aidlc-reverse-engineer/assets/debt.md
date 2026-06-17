# Technical Debt — Output Template

**Path**: `{OUTPUT_DIR}/debt.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: count by severity, brief characterization of codebase health
  risk_heatmap: table (module, complexity, test coverage, coupling, debt items, overall risk 🟢/🟡/🔴)
  debt_inventory: table (item #, name, type, severity, location, description)
    types: complexity, dead-code, coverage, dependency, inconsistency, missing-abstraction, security, architecture
  complexity_hotspots: table (file:line, function, cyclomatic complexity, lines, issue)
  test_assessment:
    - coverage_overview: table (module, unit/integration/e2e tests, ratio, critical paths tested)
    - quality_signals: table (signal, status, details) — framework, flaky tests, excessive mocking, missing types, speed
    - coverage_gaps: table (area, type, impact, description)
  dependency_issues: table (package, issue, current version, latest, risk)
  architectural_debt: table (issue, type, modules affected, description, remediation)
    types: circular-dependency, god-module, leaky-abstraction, wrong-layer, tight-coupling
  remediation_priorities: table (priority, item, effort, impact, rationale)
```

## Rules
- Complexity measured from actual code (nesting depth, function length, parameter count)
- Test coverage gaps prioritized by business criticality, not just line count
- Remediation ordered by severity × business impact
