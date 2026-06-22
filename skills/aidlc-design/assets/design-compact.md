# Compact Design — Output Template

**Path**: `{SPECS_DIR}/{feature}/design.md`
**Use when**: Simple projects (≤10 stories, single domain) — single file, no `design/` folder.

## Structure

```yaml
sections:
  summary: architecture, stack, component/entity/endpoint counts
  architecture: pattern (from D3 with rationale), ascii_diagram
  components: # per component
    - purpose, technology, responsibilities, exposes, consumes
  data_model: # per entity
    - fields (name/type/constraints), relationships, indexes
  api_specification:
    - conventions (pagination, rate limit, versioning)
    - endpoints: method, path, auth, request, response, errors
  integration_points: # if any — system, protocol, purpose, error_handling
  implementation: directory_structure, dev_setup, conventions
  testing_strategy: # if D3 testing answers exist and project ≠ prototype
    - test_pyramid: unit/integration/e2e ratio and philosophy
    - frameworks: per layer (unit, integration, e2e, pbt, load — from D3)
    - coverage_targets: percentage or qualitative goals
    - mock_strategy: external services, database, time-dependent
    - test_data: seeding, cleanup, isolation approach
    - run_commands: per test type + full suite
  nfr: # if D3 NFR answered — performance, security, scalability targets
  correctness: # if D3 PBT = Yes — property table (name, description, validates)
  traceability: # MANDATORY — every US-* must appear
    - table: requirement | component(s) | endpoint(s) | entity | status
    - coverage_summary: X/Total covered, list gaps with reason
    - components_without_requirement: list with justification (infra, shared, etc.)
  external_references: # if resources used — source, type, used_in
```

## Rules
- All D3 choices must be reflected
- Every story maps to at least one component + endpoint + entity
- Traceability table must list ALL US-* from requirements.md — mark gaps as "⚠️ Gap" with reason
- Keep concise — single file, not a design folder
