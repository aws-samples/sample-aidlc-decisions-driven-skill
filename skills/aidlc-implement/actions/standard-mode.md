# Action: implement (Standard Mode)

Execute tasks one at a time in order from tasks.md (phase by phase, task by task). Ignore Execution Waves section.

For each task:

## 1. Read task details and design specs

Read the task entry from tasks.md. Read related design documents referenced by the task (Ref fields). If `{BLUEPRINTS_DIR}/resources.md` lists available resources, use them:
- **Design tool**: Use MCP to read exact specs → implement UI precisely
- **API specs**: Read OpenAPI/GraphQL schemas → generate types, route stubs, validation
- **Documentation**: Use web search to look up library APIs or troubleshoot errors
- Only access external resources when the current task needs them

## 2. First task (project setup)

If this is the first task (typically project scaffold/setup):
- Initialize project structure from `design/implementation.md`
- Create directory layout, install dependencies, configure build tools
- Generate type stubs from `design/data-model.md`
- Generate API route stubs from `design/api-spec.md`
- Generate component stubs from `design/components.md`
- Generate test scaffold if D4 chose test-first/TDD

## 3. Implement following D4 testing approach

Read testing approach from D4 decisions:
- **TDD**: Write failing tests first → implement to pass → refactor
- **Test-after**: Implement the feature → write tests → verify
- **Outside-in**: Write acceptance test → implement from outer layer inward

Follow design specs precisely. Use the exact frameworks, patterns, and conventions specified.

## 4. Run tests and verify

Run the test suite. Only mark task complete when all tests pass. If tests fail:
- Read the error output
- Fix the implementation (not the test, unless the test has a bug)
- Re-run until passing

## 5. Mark task complete (environment-aware)

- **Kiro**: Use `taskStatus` tool
- **Claude Code**: Use `TaskUpdate` tool OR `Edit` to change `- [ ]` → `- [x]`

## 6. Update manifest

- **Incremental**: Set `units[{unit}].implementation.currentTask`, increment `completedTasks`
- **Comprehensive**: Set `implementation.currentTask`, increment `completedTasks`

## 7. Present per-task results

```
📍 Implementation: Task {X.Y} complete ({Z}% overall)

- **Files changed**: [count]
- **Tests**: [new] new, [total] total, all passing: [yes/no]
- **What's testable now**: [endpoints, features, or components that are functional]
- **Next**: Task {next ID} — {next title}

---
🔲 **Your turn**:
- ✅ "next" — proceed to next task
- ✏️ "change [what]" — request changes to this task
- ⏸️ "pause" — stop here, resume later
```

**STOP and wait for approval**, then proceed to next task.

## 8. Append audit entry

```
### [{ISO timestamp}] Task Complete: {Task ID} — {Task Title}

**Phase**: implementation
**Action**: task {Task ID} implemented (standard mode)
**Artifacts**: {files created/modified}
**Outcome**: {pass/fail}, {test count} tests, {Z}% overall progress
```

For incremental mode: full entry to unit audit, one-line summary to feature audit.

---

## When all tasks complete

Load `{SKILL_DIR}/actions/finalize.md` and follow its instructions.
