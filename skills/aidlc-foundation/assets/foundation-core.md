# Foundation Specification — Output Template

**Path**: `{SPECS_DIR}/{feature}/foundation.md`
**Condition**: Incremental mode, 2+ units. For team-specific sections, also load `foundation-team.md` when team size > 1.

## Structure

```yaml
sections:
  summary: # 10-line max, downstream reads ONLY this
    - team, repo, architecture, gateway, auth, error_format
    - inter_unit_comms, database, shared_types, frontend, infra_units
  repository_structure:
    - strategy: Monorepo/Multi-repo/Hybrid with rationale
    - directory_tree: language-idiomatic layout showing all units
    - note: "Include ALL units from units.md — both frontend and backend"
  api_architecture: # microservices/distributed ONLY, skip for monolith
    - pattern: Gateway/BFF/Direct/Hybrid with rationale
    - routing_rules: how requests reach services
  auth:
    - approach: from DF
    - authorization_model: RBAC/ABAC/simple
    - enforcement_point: Gateway/Unit/Both
    - shared_contract: "AuthContext { userId, roles, permissions }"
  error_handling:
    - format: from DF
    - code_convention: "[DOMAIN]_[NUMBER]" pattern
    - standard_shape: "{ code, message, status, details?, requestId }"
    - shared_codes: VALIDATION_001(400), AUTH_001(401), AUTH_002(403), NOT_FOUND(404), INTERNAL(500)
  inter_unit_communication:
    - pattern: from DF
    - convention: URL/event/service naming patterns
    - timeout_retry: policy
    - event_schema: if event-driven, show DomainEvent<T> shape
  database_strategy:
    - approach: from DF
    - schema_convention: naming, cross-access rules
  shared_types:
    - strategy: from DF
    - location_or_tool: where types live or how generated
  code_conventions:
    - versioning: packages (semver), API (url/header), breaking change policy
    - language: from DF with version
    - runtime: from DF
    - package_manager: from DF
    - naming: language-idiomatic conventions
    - testing: language-standard runner
    - linting: language-standard tools
    - data: ID format, timestamps, soft deletes
  integration_contracts: # per unit pair
    per_pair:
      - endpoints: sketch (METHOD /path → purpose)
      - key_data_shape: in project's primary language
      - events: if event-driven
  infrastructure_units: # if any from DF
    per_unit:
      - type: infrastructure, source: foundation
      - purpose, priority, responsibilities
      - depended_on_by: domain units
  logging_observability:
    - log_format: structured JSON or plain
    - correlation: request ID header
    - log_levels: error, warn, info, debug
  cicd:
    - branch_strategy: from DF
    - pipeline_tool: from DF
    - stages: table with stage, trigger, actions
    - environments: table with env, trigger, URL pattern
    - deployment_strategy: from DF with rollback approach
```

## Conditional Generation (based on "Shared Foundations Level" from DF)
- **Minimal**: ONLY code_conventions + error_handling
- **Standard**: + auth + inter_unit_communication + database_strategy
- **Comprehensive**: ALL sections

## Rules
- Make ALL content concrete using the primary language/runtime from DF
- Use language-idiomatic directory layouts, tools, and syntax
- Integration contracts are sketches — full specs defined during unit design
- Infrastructure units get added to units.md with `Source: foundation`
