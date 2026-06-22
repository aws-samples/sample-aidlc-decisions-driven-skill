# Action: Run Build and Tests

## 1. Run build

Execute the detected build command. Capture output.

**On success**:
```
✅ Build passed ({duration})
```

**On failure**:
```
❌ Build failed

{error output — truncated to relevant lines}

🔲 **Your turn**:
- 🔧 "fix" — I'll attempt to resolve the build error
- 🔁 "retry" — run build again (after manual fix)
- ⏭️ "skip build" — proceed to tests anyway
```

**STOP on failure and wait.**

If user says "fix": analyze the error, apply minimal fix, re-run build. Do NOT refactor or change architecture — only fix compilation/build errors. If fix requires design changes, recommend going back to implement phase.

---

## 2. Run test suite

Execute test commands in order:

1. **Unit tests**: `{test command}` (or `{test command} --unit` if framework supports filtering)
2. **Integration tests**: `{test command} --integration` (if configured separately)
3. **E2E tests**: `{e2e command}` (if configured — e.g., `cypress run`, `playwright test`)

For each suite, capture:
- Pass/fail count
- Duration
- Coverage percentage (if reporter configured)
- Failed test details (name, assertion, file:line)

**Present results incrementally** — show each suite as it completes:

```
📍 Test Results

| Suite | Tests | Passed | Failed | Duration | Coverage |
|---|---|---|---|---|---|
| Unit | {n} | {p} | {f} | {d} | {c}% |
| Integration | {n} | {p} | {f} | {d} | — |
| E2E | {n} | {p} | {f} | {d} | — |

{If failures exist:}
### Failures

1. `{test name}` — {assertion message} ({file}:{line})
2. ...
```

**On all pass**: proceed to quality gates (step 3).

**On failures**:
```
🔲 **Your turn**:
- 🔧 "fix" — I'll attempt to fix failing tests
- 🔁 "retry" — run tests again
- ⏭️ "skip failures" — proceed with known failures
- ↩️ "back to implement" — return to fix in implementation phase
```

**STOP and wait.**

If user says "fix": analyze failures, apply minimal fixes. Distinguish between:
- **Test bug** (test assertion wrong) → fix the test
- **Code bug** (implementation wrong) → fix the code
- **Integration issue** (components don't connect) → fix wiring

Re-run affected tests after fix. If fix requires significant refactoring, recommend returning to implement phase.

---

## 3. Implementation traceability check

After tests pass (or user accepts failures), verify that all tasks were actually implemented:

### Tasks → Code (forward trace)
1. Read `tasks.md` — collect all task IDs (`N.M` patterns) from checkboxes
2. For each task marked `[x]` (complete):
   - Verify at least one source file exists that corresponds to the task's purpose
   - Cross-reference against the `**Ref**` design section — the component/endpoint/entity from design should have a corresponding file
3. For each task still marked `[ ]` (incomplete):
   - Flag as `⚠️ Not implemented`

### Requirements → Code (end-to-end trace)
1. Read `requirements.md` — collect all `US-*` IDs
2. Read `tasks.md` `requirements_coverage` section — get the task IDs mapped to each US-*
3. For each US-*: check whether its mapped tasks are all `[x]` complete
4. Produce a coverage matrix:

```
| Requirement | Tasks | Completed | Status |
|---|---|---|---|
| US-01 | 1.1, 1.2, 2.1 | 3/3 | ✅ Covered |
| US-02 | 3.1, 3.2 | 1/2 | ⚠️ Partial |
| US-03 | 4.1 | 0/1 | ❌ Not implemented |
```

### Present traceability results

```
📍 Implementation Traceability

- **Tasks completed**: [X] / [Total]
- **Requirements fully covered**: [Y] / [Total US-*]
- **Partial coverage**: [Z] requirements (some tasks incomplete)
- **Not implemented**: [W] requirements (no tasks complete)

{If gaps exist:}
⚠️ Coverage gaps detected:
- US-{N}: {task IDs incomplete} — {component/feature affected}

🔲 **Your turn**:
- ⏭️ "proceed" — accept current coverage and continue to quality gates
- ↩️ "back to implement" — return to complete missing tasks
```

**STOP if gaps exist and wait.** If all requirements are fully covered, proceed silently to quality gates.

---

## 4. Run quality gates

Execute each configured gate. Report results:

### Lint
```bash
{lint command}  # e.g., eslint ., ruff check ., cargo clippy
```

### Type-check
```bash
{typecheck command}  # e.g., tsc --noEmit, mypy ., pyright
```

### Security scan
```bash
{security command}  # e.g., npm audit, cargo audit, safety check, snyk test
```

### Coverage threshold
Compare reported coverage against threshold (from testing-strategy.md or config):
- If coverage < threshold → report as gate failure
- If no threshold configured → report coverage as informational

**Present gate results**:
```
📍 Quality Gates

| Gate | Status | Details |
|---|---|---|
| Lint | ✅ / ❌ | {N} errors, {M} warnings |
| Type-check | ✅ / ❌ | {N} errors |
| Security | ✅ / ❌ / ⚠️ | {N} critical, {M} high, {O} moderate |
| Coverage | ✅ / ❌ | {X}% (threshold: {Y}%) |
```

**All gates pass** → proceed to report (load `{SKILL_DIR}/actions/report.md`).

**Gate failures**:
```
🔲 **Your turn**:
- 🔧 "fix" — I'll resolve the failures
- ⏭️ "proceed anyway" — accept current state and continue
- ↩️ "back to implement" — return to fix in implementation phase
```

**STOP and wait.**

Quality gate failures are advisory — the user decides whether to fix or proceed. Security criticals should be flagged strongly but are still the user's call.

---

## 5. Audit entry

After all steps complete (or user decides to proceed):

```
### [{ISO timestamp}] Build: Verification

**Phase**: build
**Action**: build-run, test-run, quality-check
**Artifacts**: (source code verified, no new files)
**Outcome**: Build {passed/failed}. Tests: {X} passed, {Y} failed. Gates: {N} passed, {M} failed, {O} skipped.
```
