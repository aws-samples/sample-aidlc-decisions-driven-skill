# Implementation: Parallel Mode

Execute phases in dependency waves from the `## Execution Waves` section in tasks.md. Each wave contains one or more top-level phases. Phases within a wave run simultaneously via sub-agents. Tasks within each phase are executed sequentially by the assigned sub-agent.

## Prerequisites

Before starting, verify the environment supports parallel execution:

- **Kiro IDE**: Ensure user is in **Autopilot mode** (no per-tool prompts needed)
- **Kiro CLI**: Instruct user to run `/tools trust-all` or `/tools trust read write shell` to avoid per-tool prompts
- **Claude Code**: No special prerequisite needed

Only show the prerequisite that matches the detected environment.

## For each wave:

### Step 1 — Present wave plan

```
📍 Implementation: Wave {N} of {total} ({X}% complete)

- **Phases in this wave**: [list of phase names]
- **Tasks**: [count of tasks across all phases in wave]
- **Execution**: Parallel ([X] sub-agents)
- **File ownership**: [summary of which phase owns which directories]

---
🔲 **Your turn**:
- ✅ "go" — execute this wave
- 📋 "details" — show full task list for this wave
```

**STOP and wait for "go".**

### Step 2 — Dispatch sub-agents

Dispatch one sub-agent per phase in the wave. You MUST use `invokeSubAgent` (Kiro) or `Agent` (Claude Code). ALL calls MUST appear in the same response. NEVER implement tasks yourself — your role is dispatch and coordination only.

Sub-agents execute in isolated contexts with their own tool access, preventing file conflicts between phases. This is why dispatch is required — direct implementation cannot guarantee file ownership isolation.

**Sub-agent prompt template** (fill per phase):

```
You are a Senior Software Engineer. Implement {phaseName} ({taskCount} tasks).

## Tasks
Execute these tasks in order:

{Copy full task entries from tasks.md including sub-items, deps, and refs}

## Design References
Read these files for implementation guidance:
- `{designDir}/design.md` — overall design
- `{designDir}/design/implementation.md` — project structure
- `{designDir}/design/data-model.md` — entities and schemas
- `{designDir}/design/api-spec.md` — endpoints (if applicable)
- `{designDir}/design/components.md` — components (if applicable)
{If incremental: "- Foundation unit design docs at `{SPECS_DIR}/{feature}/units/foundation/design/` — shared conventions (auth, error handling, comms, DB strategy)"}

Where {designDir} = `{SPECS_DIR}/{feature}` (comprehensive) or `{SPECS_DIR}/{feature}/units/{unit}` (incremental).

## Testing Approach
{D4 testing approach: TDD / test-after / outside-in}

## Feature
Feature name: {feature}. Manifest at: {WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml
{If incremental: "Unit: {unit}. Unit artifacts at: {SPECS_DIR}/{feature}/units/{unit}/"}

## File Ownership
You may ONLY create or modify files in: {ownership paths for this phase from Execution Waves}
Do NOT modify files outside your ownership.

## Instructions
1. Read the design references above
2. Implement each task in order following design specs precisely
3. Write tests following the testing approach
4. Use shell/Bash to install dependencies, run migrations, execute tests
5. Verify all tests pass before reporting completion
6. Report: files changed per task, tests written, test results
```

**CRITICAL**: Emit one sub-agent call per phase. Do NOT implement tasks yourself. Even if a wave contains only 1 phase, dispatch a sub-agent for it.

### Step 3 — Post-execution

After ALL sub-agents complete:
1. **Check each sub-agent's report**: if any tasks are reported failed or incomplete, do NOT mark them complete. Present the failures:

   ```
   ⚠️ Wave {N}: [X] task(s) failed in {phase}
   - Task {ID}: {error summary}

   🔲 **Your turn**:
   - 🔁 "retry [phase]" — re-dispatch a sub-agent for the failed tasks
   - 🔧 "fix" — I'll resolve the failures directly
   - ⏭️ "skip [task ID]" — leave incomplete and continue (tasks in later waves that depend on it will be skipped)
   ```

   **STOP and wait.** Proceed only when every task in the wave is complete or explicitly skipped.
2. Run the full test suite to verify no conflicts between parallel phases
3. If tests fail → load `{SKILL_DIR}/actions/resolve-conflict.md` and follow its instructions
4. Mark completed wave tasks complete (environment-aware, same as standard mode) — never mark failed or skipped tasks
5. Update manifest: update `implementation.completedTasks` with the completed tasks from this wave AND set `implementation.currentWave` to `{N+1}` so recovery can resume at the correct wave. **Incremental mode**: same fields under `units[{unit}].implementation`.

### Step 4 — Present wave results

```
📍 Implementation: Wave {N} complete ({X}% overall)

- **Phases completed**: [list]
- **Files changed**: [count]
- **Tests**: [new] new, [total] total, passing: [yes/no]
- **Conflicts**: [none / resolved — brief description]
- **Next**: Wave {N+1} — [phase list]

---
🔲 **Your turn**:
- ✅ "next" — proceed to next wave
- 🔍 "review [phase]" — inspect a specific phase's output
- ⏸️ "pause" — stop here, resume later
```

**STOP and wait**, then proceed to next wave.

**Append audit entry after each wave:**

```
### [{ISO timestamp}] Wave Complete: Wave {N}

**Phase**: implementation
**Action**: wave {N} executed (parallel mode, {X} sub-agents)
**Artifacts**: {list of phases completed, file counts}
**Outcome**: {pass/fail}, {test count} tests, {Z}% overall progress, conflicts: {none/resolved}
```

For incremental mode: write full entry to `{WORKFLOW_DIR}/{feature}/units/{unit}/audit.md` and a one-line summary to `{WORKFLOW_DIR}/{feature}/audit.md`.

After all waves complete, load `{SKILL_DIR}/actions/finalize.md` and follow its instructions.
