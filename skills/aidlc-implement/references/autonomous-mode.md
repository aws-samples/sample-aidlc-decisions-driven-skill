# Implementation: Autonomous Mode

Execute all waves without stopping for user approval. Uses the Execution Waves section from tasks.md for dependency ordering.

> ⚠️ **CRITICAL: You are the ORCHESTRATOR in autonomous mode. You MUST dispatch sub-agents for implementation — do NOT write code yourself. This applies to ALL waves, including single-phase waves. The only difference from parallel mode is that you do not wait for user approval between waves.**

## Prerequisites

Same as parallel mode:
- **Kiro IDE**: Autopilot mode required
- **Kiro CLI**: `/tools trust-all` or `/tools trust read write shell`
- **Claude Code**: No special prerequisite

Only show the prerequisite that matches the detected environment.

## Step 1 — Present full plan

```
📍 Implementation: Autonomous Mode — Full Plan

**Total**: [X tasks] across [Y phases] in [Z waves]
**Testing**: {D4 approach}
**Estimated sub-agents**: [total across all waves]

Wave breakdown:
- Wave 1: [phases] ([task count] tasks)
- Wave 2: [phases] ([task count] tasks)
- ...

⚠️ Autonomous mode will execute all waves without stopping.
Failed tasks will be retried up to 5 times, then skipped.
Tasks depending on failed tasks will also be skipped.

---
🔲 **Your turn**:
- ✅ "go" — start autonomous execution
- 🔀 "standard" / "parallel" — switch to a different mode
```

**STOP and wait for "go".**

## Step 2 — Execute all waves

For each wave, dispatch one sub-agent per phase (same as parallel mode — see `references/parallel-mode.md` for sub-agent prompt template). ALL calls for a wave MUST appear in the same response. Do NOT implement tasks yourself.

After each wave completes:
1. Run full test suite
2. If conflicts → load `{SKILL_DIR}/actions/resolve-conflict.md` and follow its instructions
3. Mark completed tasks complete (never failed `[!]` or skipped tasks — see Failure Handling), update manifest (`completedTasks` + set `currentWave` to the next wave number so recovery can resume at the correct wave; unit-scoped in incremental mode), append audit entry
4. **Do NOT wait for user approval** — proceed immediately to next wave

## Failure Handling

- If a task fails (tests don't pass after implementation): read the error, attempt fix, re-test
- Retry up to **5 times**. If the same error or test failure repeats in consecutive attempts, stop early — the AI is stuck
- After exhausting retries: mark task as `failed` in tasks.md (change `- [ ]` to `- [!]`), log the failure reason and attempts made, continue to next task
- Before starting each task: check if all its dependencies are marked complete. If any dependency is `failed` (`[!]`) → skip this task, mark as `skipped (dependency failed: {taskId})`, continue
- Track all failures and skips for the final summary

## Shell Commands

Always use non-interactive flags (`-y`, `--yes`, `--no-input`, `--non-interactive`). Use defaults for any prompts. Do not wait for user input during execution.

## Step 3 — Final autonomous summary

After all waves complete, present the autonomous summary:

```
📍 Implementation: Autonomous Mode Complete

**Completed**: [X] of [Y] tasks
**Failed**: [F] tasks [list IDs if any]
**Skipped**: [S] tasks (dependency failures) [list IDs if any]
**Files changed**: [count]
**Tests**: [total] total, [passing] passing, [failing] failing

[If failures exist:]
⚠️ Tasks requiring manual attention:
- Task {ID}: {failure reason}
- Task {ID}: skipped (dependency: {dep ID} failed)

---
🔲 **Your turn**:
- ✅ "done" — accept results
- 🔧 "fix [task ID]" — manually address a failed task
- 🔍 "review" — inspect implementation details
```

Then load `{SKILL_DIR}/actions/finalize.md` and follow its instructions, **skipping its final-summary presentation** — the summary above replaces it, and the user's "done" here counts as the approval its manifest-update step waits for. Do not present two consecutive summaries or two "done" gates.
