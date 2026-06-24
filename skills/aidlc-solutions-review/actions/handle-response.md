# Action: handle-response

## User Response Handling

After presenting review results, handle user response:

### "fix [issue]"

1. Identify which unit's design needs to change based on the finding
2. Recommend the specific edit needed
3. Auto-continue: read `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md` and begin the design-edit action for the affected unit

### "proceed"

1. Update manifest — add `artifacts.solutions-review` entry:
   ```yaml
   status: "approved"
   timestamp: "{ISO timestamp}"
   files: [architecture-review.md]
   ```
2. Recommend next step based on manifest state (typically: activate `aidlc-tasks` for the next unit, or select next unit from decomposition)

### "re-review"

Re-run the review from Step 1 (load `{SKILL_DIR}/actions/review.md`) with updated design documents.
