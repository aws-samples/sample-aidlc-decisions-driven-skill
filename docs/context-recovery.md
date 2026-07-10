# Context Recovery

Every skill includes a context recovery mechanism. If the AI's context window is compacted mid-phase, the workflow can resume without losing progress.

## How It Works

1. Read the platform shim (`.kiro/steering/aidlc.md` or `.claude/CLAUDE.md`) for behavioral anchors and the manifest pointer
2. Read the manifest for current phase and artifact paths
3. Read `.aidlc/blueprints/*` for project content (product, tech, structure, resources, corrections)
4. Read the skill's `SKILL.md` to reload instructions
5. Resume from the current action

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

## Platform Shim Role

The platform shim — `.kiro/steering/aidlc.md` (Kiro, `inclusion: always`) or `.claude/CLAUDE.md` (Claude Code) — is automatically loaded every session. It carries the behavioral anchors inline, points to the manifest, and references the blueprints (`.aidlc/blueprints/*`), giving the AI enough context to find its way back even without an explicit "resume" command. Because the shim references shared blueprints rather than duplicating content, recovery works identically across platforms.
