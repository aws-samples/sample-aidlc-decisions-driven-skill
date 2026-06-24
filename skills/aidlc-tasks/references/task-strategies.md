# Task Breakdown Strategies

## Vertical Slice (Recommended)
Each task delivers a complete user-facing feature across all layers.
**Pros**: Delivers value incrementally, easier to demo, clear progress
**Cons**: May touch multiple layers, harder to parallelize

## Layer-by-Layer
Tasks organized by technical layer.
**Pros**: Clear technical separation, easier to parallelize
**Cons**: No user value until all layers complete, integration risk

## Feature-by-Feature
Tasks organized by functional area.
**Pros**: Clear feature boundaries, easier to prioritize
**Cons**: May have dependencies between features

## Component-First
Build shared components before features.
**Pros**: Reusable components, consistent patterns
**Cons**: Risk of over-engineering, delayed user value

## Task Sizing Rules
- Break down tasks so each has a **single concern** — one component, one endpoint, one test suite
- Good sizes: single CRUD operation, one UI component, one API endpoint, unit tests for one module
- Too large: "Implement entire authentication system", "Build complete user management"
- Too small: "Add import statement", "Create empty file" (unless it's a distinct config step)

## Testing Task Patterns

### TDD Pattern (Test-First)
Generate test tasks **before** implementation tasks within the same phase:
1. `Write test for [component]` — create test file with failing tests based on design spec
2. `Implement [component]` — write code to make tests pass
3. `Verify [component] tests pass` — run suite, fix any remaining failures

**Sizing**: Test skeleton tasks are smaller (atomic). Implementation tasks assume tests exist.

### Test-After Pattern (Default)
Generate implementation tasks first, testing tasks follow:
1. `Implement [component]` — includes inline note: "Write unit tests after"
2. `Write unit tests for [component]` — separate task or embedded as sub-bullet
3. `Integration tests for [feature area]` — typically a dedicated phase/task

**Sizing**: Integration/E2E test tasks are full tasks. Unit tests are often embedded in implementation tasks.

### Outside-In Pattern
Generate from outer to inner layers:
1. `E2E test skeleton for [user flow]` — write failing E2E test
2. `Integration test for [endpoint]` — write failing integration test
3. `Implement [endpoint/component]` — make integration test pass
4. `Verify E2E test passes` — confirm outer test now passes

**Sizing**: Each layer's test skeleton is a task. Implementation fills in to pass tests.

### Testing Task Sizing Guidance

| Test Type | Scope | Notes |
|-----------|-------|-------|
| Unit test for 1 component | Atomic | Often embedded in implementation task |
| Integration tests for 1 feature area | Single-concern | Includes test DB setup, assertions |
| E2E setup (framework + config) | Atomic | One-time setup task |
| E2E scenarios (per critical flow) | Single-concern | 1 task per user flow |
| Load test setup + scenarios | Single-concern | Includes baseline definition |
| PBT properties (per property) | Single-concern | Depends on generator complexity |

### When to Separate vs Embed Test Tasks

**Separate test tasks** when:
- E2E or load tests (always separate — different tooling, environment)
- Integration tests spanning multiple components
- PBT properties (complex generator setup)
- TDD mode (test-first requires explicit ordering)

**Embed in implementation tasks** when:
- Unit tests for a single component (Test-After mode)
- Simple assertion tests alongside implementation
- The test is trivial given the implementation
