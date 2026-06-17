# Tasks — Output Template

**Path**: `{SPECS_DIR}/{feature}/tasks.md`

**CRITICAL**: Use Kiro-compatible checkbox format:
- Phase = top-level: `- [ ] 1. Phase Name`
- Task = nested: `  - [ ] 1.1 Task Title`
- Details = plain list items (no checkbox)

## Structure

```yaml
sections:
  summary: total_tasks, phases, waves, strategy, testing_approach, derived_from
  overview: strategy_rationale, checkbox_legend, derived_from cross-reference
  task_phases: # main content — checkbox format
    per_phase: "- [ ] N. Phase Name"
      per_task: "  - [ ] N.M Task Title"
        - "**Deps**: task IDs | **Ref**: design file — section"
        - implementation details, testing requirements
  task_summary: table (task ID, title, dependencies, status)
  requirements_coverage: US-N → implementing tasks → status
  design_coverage: components/entities/endpoints → task IDs
  testing_coverage:
    - unit_test_tasks: [task IDs covering unit tests per component]
    - integration_test_tasks: [task IDs covering integration tests per endpoint]
    - e2e_test_tasks: [task IDs for E2E scenarios] (if E2E framework in D3)
    - load_test_tasks: [task IDs for load test scenarios] (if load testing in D3)
    - pbt_tasks: [task IDs for PBT properties] (if PBT in D3)
    - coverage_summary: components with tests / total components, endpoints with tests / total endpoints
  definition_of_done: checklist (code, tests, review, docs, AC met)
  execution_waves:
    - wave_table: wave number, phases, resolved dependencies
    - file_ownership: per wave per phase — owned directories/files
  notes: technical_debt, future_enhancements
```

## Rules
- Every design component, entity, and endpoint must have at least one task
- Every user story must appear in requirements_coverage
- Every component must have associated unit test task(s) in testing_coverage
- Every endpoint must have integration test coverage in testing_coverage
- If E2E framework selected in D3, E2E tasks must exist for critical user flows
- If load testing selected in D3, load test tasks must exist
- If TDD selected in D4, test tasks must precede their implementation tasks within the same phase
- Dependencies reference task IDs (e.g., "1.1, 2.3") — no circular deps
- Ref links to specific design file and section
- Tasks sized for 1-2 days (split if larger)
- File ownership in parallel waves must NOT overlap between phases
