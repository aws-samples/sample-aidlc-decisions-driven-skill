# Action: apply-fixes

When user says "fix [issue]" or "fix all":

1. **Create safety checkpoint**: Run `git stash push -m "aidlc-code-review-backup"`. If not a git repo, warn and wait for confirmation.
2. For each fix to apply:
   - Read the current file
   - Apply the suggested change from the review report
   - Verify the fix doesn't break existing tests (run test suite)
3. After applying fixes:
   - If tests fail: restore (`git stash pop`), report which fix caused failure, suggest applying individually
   - If tests pass: drop stash (`git stash drop`), re-run review on changed files (quick re-check), present results
4. If "fix all": apply in order — critical first, then major, then minor. Stop if a fix breaks tests, restore, report which failed.
