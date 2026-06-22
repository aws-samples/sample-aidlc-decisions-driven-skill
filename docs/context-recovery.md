# Context Recovery

Every skill includes a context recovery mechanism. If the AI's context window is compacted mid-phase, the workflow can resume without losing progress.

## How It Works

1. Read `{STEERING_DIR}/aidlc-workflow.md` for the manifest path
2. Read the manifest for current phase and artifact paths
3. Read the skill's `SKILL.md` to reload instructions
4. Resume from the current action

The manifest and audit trail provide enough state to pick up where you left off.

## Recovery Triggers

- Context window compaction (long sessions)
- Session interruption (closing IDE, network issues)
- Switching between sessions
- Explicit "resume" command

## What Gets Preserved

| State | Where Stored | Survives Recovery |
|---|---|---|
| Current phase | Manifest `state.sharedPhases` | Yes |
| Current unit | Manifest `units[].phase` | Yes |
| Decision answers | `decisions-{phase}.md` files | Yes |
| Generated artifacts | Spec files on disk | Yes |
| Implementation progress | Manifest `implementation.currentTask` | Yes |
| Conversation context | In-memory only | No (rebuilt from manifest) |

## Manual Recovery

If automatic recovery fails, you can always:

1. Say **"resume"** — the orchestrator reads the manifest and presents current state
2. Say **"repair"** — rebuilds the manifest from disk artifacts (if manifest is corrupted)
3. Say **"status"** — shows full progress dashboard without advancing

## Steering File Role

The `aidlc-workflow.md` steering file is automatically included in every session (on platforms that support it). It contains the manifest path and a brief workflow overview, giving the AI enough context to find its way back even without explicit "resume" commands.
