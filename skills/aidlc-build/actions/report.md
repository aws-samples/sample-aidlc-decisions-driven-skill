# Action: Generate Build Report

## 1. Generate build-report.md

Write to `{WORKFLOW_DIR}/{feature}/build-report.md`:

```markdown
# Build Report — {feature}

**Date**: {ISO timestamp}
**Platform**: {platform}
**Ecosystem**: {ecosystem}
**Status**: {passed | passed-with-warnings | failed}

## Build

| Metric | Value |
|---|---|
| Command | `{build command}` |
| Status | {passed/failed} |
| Duration | {duration} |
| Output size | {artifact size if applicable} |

## Tests

| Suite | Tests | Passed | Failed | Skipped | Duration | Coverage |
|---|---|---|---|---|---|---|
| Unit | {n} | {p} | {f} | {s} | {d} | {c}% |
| Integration | {n} | {p} | {f} | {s} | {d} | — |
| E2E | {n} | {p} | {f} | {s} | {d} | — |
| **Total** | {N} | {P} | {F} | {S} | {D} | {C}% |

{If failures were skipped:}
### Known Failures (accepted)
- `{test name}` — {reason for acceptance}

## Quality Gates

| Gate | Status | Details |
|---|---|---|
| Lint | {status} | {details} |
| Type-check | {status} | {details} |
| Security | {status} | {details} |
| Coverage | {status} | {X}% (threshold: {Y}%) |

{If gates were skipped:}
### Skipped Gates
- {gate} — skipped by user

## Summary

{One-paragraph summary: what was verified, what passed, what was accepted with known issues}

## Implementation Traceability

| Requirement | Mapped Tasks | Completed | Status |
|---|---|---|---|
| [US-X] | [task IDs] | [X/Y] | ✅ Covered / ⚠️ Partial / ❌ Not implemented |

### Coverage
- **Requirements fully covered**: [X] / [Total]
- **Partial**: [Y] (list)
- **Not implemented**: [Z] (list)
- **Tasks completed**: [A] / [B] total
```

---

## 2. Track the report in the manifest (draft)

```yaml
artifacts.build:
  status: "draft"        # approval happens in step 4 — never pre-approve
  timestamp: "{ISO timestamp}"
  files: [build-report.md]
```

---

## 3. Present for approval

```
📍 Build Verification Complete

- **Build**: {passed/failed}
- **Tests**: {P}/{N} passing ({C}% coverage)
- **Quality gates**: {X}/{Y} passed
- **Report**: {WORKFLOW_DIR}/{feature}/build-report.md

🔲 **Your turn**:
- ✅ "deploy" — approve and proceed to deployment configuration
- 🔍 "details" — show full report
- 🔧 "fix [issue]" — address remaining issues
- ↩️ "back to implement" — return to implementation
```

**STOP and wait.**

---

## 4. Handle response

**On "deploy" / "proceed" / "next" (approval)** — only now update the manifest:

```yaml
artifacts.build.status: "approved"   # or "approved-with-warnings" if failures/gates were accepted
state.sharedPhases: [...existing, "build"]
```

Append the audit entry:

```
### [{ISO timestamp}] Build: Report Approved

**Phase**: build
**Action**: build-approved
**Artifacts**: build-report.md
**Outcome**: Build verified. {X} tests passing, {Y} quality gates met. Proceeding to deploy.
```

Then hand off to `aidlc-deploy`.

**On "fix [issue]"**: apply the fix, re-run the affected verification, regenerate the report (step 1), re-present. Status stays `"draft"`.

**On "back to implement"**: leave `artifacts.build.status: "draft"` — do NOT add `"build"` to `sharedPhases`. Append an audit note, then dispatch `aidlc-implement`.
