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
```

---

## 2. Update manifest

```yaml
artifacts.build:
  status: "approved"  # or "approved-with-warnings" if failures were accepted
  timestamp: "{ISO timestamp}"
  files: [build-report.md]

state.sharedPhases: [...existing, "build"]
```

---

## 3. Present completion

```
📍 Build Verification Complete

- **Build**: {passed/failed}
- **Tests**: {P}/{N} passing ({C}% coverage)
- **Quality gates**: {X}/{Y} passed
- **Report**: {WORKFLOW_DIR}/{feature}/build-report.md

🔲 **Your turn**:
- ✅ "deploy" — proceed to deployment configuration
- 🔍 "details" — show full report
- 🔧 "fix [issue]" — address remaining issues
- ↩️ "back to implement" — return to implementation
```

**STOP and wait.**

On "deploy" / "proceed" / "next" → hand off to `aidlc-deploy`.

---

## 4. Audit entry

```
### [{ISO timestamp}] Build: Report Generated

**Phase**: build
**Action**: build-approved
**Artifacts**: build-report.md
**Outcome**: Build verified. {X} tests passing, {Y} quality gates met. Proceeding to deploy.
```
