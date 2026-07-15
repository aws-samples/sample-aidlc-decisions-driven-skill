# Action: apply-fixes

When user says "fix [issue]" or "fix all":

1. **Create safety backups (non-destructive)**: Before changing anything, copy each file the fixes will modify to `{WORKFLOW_DIR}/{feature}/history/code-review-{ISO}/{relative-path}`, preserving the directory structure (code equivalent of the Edit Action Pattern backup in `shared/base.md`).
   ⛔ Do NOT use `git stash` as a checkpoint — the implementation under review may be uncommitted, so stashing would remove it from the working tree, and `git stash drop` would delete it permanently. On an already-clean tree, a later pop/drop would hit an unrelated user stash.
2. For each fix to apply:
   - Read the current file
   - Apply the suggested change from the review report
   - Verify the fix doesn't break existing tests (run test suite)
3. After applying fixes:
   - If tests fail: restore the modified files from the backup directory, report which fix caused the failure, suggest applying fixes individually
   - If tests pass: re-run review on changed files (quick re-check), present results
4. If "fix all": apply in order — critical first, then major, then minor. Stop if a fix breaks tests, restore its files from the backup directory, report which fix failed.
