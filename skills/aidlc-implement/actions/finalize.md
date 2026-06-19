# Action: Finalize (All Modes)

After all tasks/waves complete (regardless of mode):

## 1. Run full test suite

Execute the complete test suite one final time. Report results.

## 2. Present final summary

```
📍 Implementation Complete

- **Total tasks**: [X] completed [/ Y failed / Z skipped — autonomous only]
- **Total files**: [count] created/modified
- **Tests**: [total] total, [passing] passing
- **Test coverage**: [percentage if available]
- **Requirements coverage**: [X of Y user stories implemented]

---
🔲 **Your turn**:
- ✅ "done" — finalize implementation
- 🔍 "review" — inspect specific areas
- 🔧 "fix [issue]" — address remaining issues
```

**STOP and wait.**

## 3. Update manifest

On user approval:
- **Incremental mode**: Set `units[{unit}].phase` to `"completed"`, add `"implement"` to `units[{unit}].completedPhases`, set `units[{unit}].status` to `"completed"`, clear `currentTask` and `currentWave`. Check if ALL units completed — if yes, add `"implement"` to `state.sharedPhases`, present: "👉 All units complete. Proceeding to build verification." Then hand off to `aidlc-build`. If not all complete, present: "👉 Return to unit selection for next unit." Then dispatch unit selection (foundation or decomposition skill depending on `state.foundationSkipped`).
- **Comprehensive mode**: Add `"implement"` to `state.sharedPhases`. Hand off to `aidlc-build`.

## 4. Append final audit entry

```
### [{ISO timestamp}] Phase Complete: Implementation

**Phase**: implementation
**Action**: all tasks implemented ({mode} mode)
**Artifacts**: {total files created/modified}, {total tests}
**Outcome**: {X} tasks completed, {Y} failed, {Z} skipped. Test suite: {pass/fail}.
```

For incremental mode: full entry to unit audit, one-line summary to feature audit.

## 5. Skill Handoff

**Next skill**: `aidlc-build` — read `{PLATFORM_DIR}/skills/aidlc-build/SKILL.md` and follow its instructions.
