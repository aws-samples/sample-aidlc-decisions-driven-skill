# Data Model — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/data-model.md`

Generate based on D3 database choice. Include ONLY the relevant schema format (relational, document, OR DynamoDB — not all).

## Structure

```yaml
sections:
  overview: database, orm_client (from D3)
  entities: # per entity
    - purpose, fields (name/type/required/constraints), relationships, indexes, business_rules
  er_diagram: ASCII with cardinality
  access_patterns: query, frequency, index used
  # Conditional — include ONE matching DB type:
  document_schema: # MongoDB/DocumentDB only
    - JSON structure, embedding rationale, indexes
  dynamodb_design: # DynamoDB only
    - key_schema (PK/SK), access_patterns, gsi_definitions, item_types
```

## Rules
- Every entity from requirements must appear
- Include realistic field types (UUID, email, URL, enum — not just "string")
- Index every field used in WHERE clauses from access patterns
- Business rules capture constraints not expressible in schema
