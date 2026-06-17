# Data Model — Output Template

**Path**: `{OUTPUT_DIR}/data-model.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: entity count, source (ORM/SQL/schema), brief characterization
  entity_inventory: table (entity, source file:line, field count, relationships)
  entity_details: # per entity
    per_entity:
      - source: file:line
      - fields: table (name, type, nullable, default, constraints)
      - relationships: table (target entity, type 1:1/1:N/N:M, FK field, cascade behavior)
      - indexes: table (name, fields, type unique/btree/gin)
      - access_patterns: detected query patterns (lookup by X, list by Y with pagination)
  er_diagram: ASCII showing entity relationships with cardinality
```

## Rules
- Extract from actual ORM models, migration files, or schema definitions — not from usage inference
- Include ALL fields, not just key ones
- Access patterns detected from repository/DAO code queries
- Cross-cutting analysis adds cross-module relationships and shared entities
