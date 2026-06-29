# Action: select-mode

After tasks are approved, present the implementation mode choice.

**⛔ HARD RULE — Per-Unit Independence**: In incremental mode, ALWAYS present the mode choice for each unit independently. Do NOT carry over a previous unit's mode selection. Even if the user chose "autonomous" for Unit 1, you MUST still ask for Unit 2. Each unit starts fresh — read `units[{current-unit}].implementationMode` from the manifest: if it is `null`, present the choice. Do NOT infer from other units or from conversation history.

## Step 1: Analyze Project

Read tasks.md (or unit-scoped tasks.md in incremental mode):
- Count total tasks (nested checkboxes `- [ ]` under phases)
- Count top-level phases (top-level checkboxes)
- Count execution waves from `## Execution Waves` section

## Step 2: Present Mode Choice

Determine recommendation based on context:
- **Scope is `bugfix` or `refactor`** → recommend standard (narrow scope, interconnected changes)
- **Solo dev OR ≤10 tasks OR learning the codebase** → recommend standard
- **2+ execution waves AND Kiro/Claude Code AND trust the spec** → recommend autonomous
- **2+ execution waves AND Kiro/Claude Code AND want review checkpoints** → recommend parallel

```
📍 Tasks Complete — Choose Implementation Mode

Your project has [X tasks] across [Y phases] in [Z execution waves].

| Mode | How It Works | Best For |
|------|-------------|----------|
| **standard** | One task at a time, review after each | Learning the codebase, tight control |
| **parallel** | Dependency waves via sub-agents, review per wave | Speed with review checkpoints |
| **autonomous** | All waves without stopping, single review at end | High confidence in the spec |

👉 **Recommended: {mode}** — {one-line rationale}

---
🔲 **Your turn**:
- ✅ "go" — use recommended mode
- Or pick: "standard" / "parallel" / "autonomous"
```

**STOP and wait for user response.** Do not auto-select a mode.

## Step 3: Handle Response

Update `aidlc-manifest.yaml`:
- **Comprehensive mode**: Set `state.implementationMode` to chosen mode. Set `implementation.totalTasks`. Standard: set `implementation.currentTask` to first task ID. Parallel/Autonomous: set `implementation.currentWave` to `1`.
- **Incremental mode**: Set `units[{unit}].implementationMode`. Set `units[{unit}].implementation.totalTasks`. Standard: set `currentTask`. Parallel/Autonomous: set `currentWave` to `1`.

Then begin implementation:
- **Standard**: Load `{SKILL_DIR}/actions/standard-mode.md` and follow its instructions
- **Parallel**: Load `{SKILL_DIR}/references/parallel-mode.md` and follow its instructions
- **Autonomous**: Load `{SKILL_DIR}/references/autonomous-mode.md` and follow its instructions
