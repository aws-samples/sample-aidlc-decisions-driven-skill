# Testing Strategy — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/testing-strategy.md`

Generated when D3 includes testing framework choices and project is not marked "prototype/no testing".

## Structure

```yaml
sections:
  overview:
    - testing_philosophy: TDD | Test-After | Outside-In | Hybrid
    - coverage_target: percentage or qualitative goal
    - test_pyramid: unit/integration/e2e ratio
  frameworks:
    - unit: framework, runner, assertion library
    - integration: framework, approach (in-memory DB, TestContainers, etc.)
    - e2e: framework, browser/runtime (if applicable)
    - pbt: framework (if selected in D3)
    - load: tool (if selected in D3)
    - api: tool (if selected in D3)
  test_architecture:
    - directory_structure: annotated tree of test folders
    - naming_conventions: file naming, test naming patterns
    - shared_utilities: factories, fixtures, helpers, mocks
    - test_data_management: seeding, cleanup, isolation strategy
  mock_strategy:
    - external_services: how to mock/stub external APIs
    - database: test DB, in-memory, mocks, or real instance
    - time_dependent: clock mocking approach
    - file_system: virtual FS or temp directories
  environment:
    - test_database: setup, migration strategy for tests
    - env_variables: test-specific configuration
    - containers: Docker/TestContainers setup (if applicable)
    - ci_integration: how tests run in CI pipeline
  coverage_mapping:
    - per_component: which test type covers each component
    - per_endpoint: which test type covers each API endpoint
    - critical_paths: user flows requiring E2E coverage
  run_commands:
    - unit: command to run unit tests
    - integration: command to run integration tests
    - e2e: command to run E2E tests (if applicable)
    - all: command to run full test suite
    - coverage: command to generate coverage report
```

## Rules

- All framework choices must come from D3 decisions — no assumptions
- Coverage mapping must reference components from `design/components.md`
- Endpoint coverage must reference endpoints from `design/api-spec.md`
- Mock strategy must align with integration approach chosen in D3
- Test directory structure must be consistent with `design/implementation.md`
- If PBT selected, reference `design/correctness.md` for property definitions
- If E2E selected, identify critical user flows from requirements for scenario coverage
- Use `[TBD - not decided in D3]` for any testing aspect not covered by D3 decisions
