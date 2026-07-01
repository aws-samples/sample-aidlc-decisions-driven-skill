# Context Rot — Prevention and Recovery

## What Is Context Rot?

Context rot occurs when an LLM gradually stops following instructions during long sessions. As the context window fills with conversation history, tool outputs, and generated artifacts, the model's attention to behavioral rules weakens. Instructions from early in the session lose influence relative to the growing body of recent content.

In the AIDLC workflow, context rot manifests as:

- Decision gates skipped entirely — agent jumps straight to generating artifacts
- Decision gate answers auto-filled instead of presented blank to the user
- Approval checkpoints (`🔲 Your turn` blocks) skipped — agent continues without waiting
- Implementation mode auto-selected without asking the user
- Agent starts writing code autonomously (autonomous mode) without explicit selection
- Manifest not updated after phase completions
- Audit entries forgotten
- Language rules violated (English leaking into non-English sessions)
- Templates generated from memory instead of read from disk

## Why It Happens

1. **Attention dilution** — As context grows, any single instruction gets proportionally less attention weight. A rule at position 500 in a 100K token context has less influence than when it was at position 500 in a 10K context.

2. **Stale instructions** — The orchestrator dispatches new skills by loading their SKILL.md, but earlier skill instructions remain physically in context, creating noise.

3. **Momentum bias** — After completing several phases successfully, the model optimizes for "continue the flow" rather than "follow the exact procedure at each step."

4. **Instruction fatigue** — Repeated patterns (STOP and wait, present options, STOP and wait) get treated as optional after enough repetitions.

## Prevention Strategies

### 1. Behavioral Anchors in Steering Files (Primary Mechanism)

Steering files persist across the entire session. On Kiro, files with `inclusion: always` are injected into every agent turn automatically. On Claude Code, `CLAUDE.md` serves the same role.

The `aidlc-workflow.md` steering file contains a "Behavioral Anchors" section with non-negotiable rules:

1. Decision gates are mandatory — generate blank → present → STOP → wait
2. Every `🔲 Your turn` block is a hard stop
3. Implementation mode requires explicit user choice
4. Read templates from disk before generating
5. Language compliance
6. Update manifest after every phase

These anchors are loaded automatically every turn — no hooks needed. They serve as constant background reinforcement that counters attention dilution in long sessions.

This approach is preferred over PreToolUse hooks because:
- **Zero overhead** — no extra processing per tool call
- **Right cadence** — once per turn, not once per file write
- **No noise** — doesn't produce visible output or slow down internal operations (audit, manifest)
- **Cross-platform** — works on both Kiro (steering) and Claude Code (CLAUDE.md)

### 2. Behavioral Anchors in Steering Files

Steering files persist across the entire session. The `aidlc-workflow.md` file (auto-included on Kiro, referenced in CLAUDE.md on Claude Code) contains a "Behavioral Anchors" section with non-negotiable rules:

1. Decision gates are mandatory — generate blank → present → STOP → wait
2. Every `🔲 Your turn` block is a hard stop
3. Implementation mode requires explicit user choice
4. Read templates from disk before generating
5. Language compliance
6. Update manifest after every phase

These anchors serve as background reinforcement throughout the session. They don't fire at a specific moment like hooks, but they maintain constant presence in context.

### 3. Skill Handoff Identity Reset

When the orchestrator dispatches a new skill, it applies a "Context override" instruction that tells the model to treat the new SKILL.md as its sole operating instructions and disregard prior skill instructions. This prevents cross-phase contamination where patterns from an earlier phase bleed into a later one.

### 4. §Summary for Chained Dispatch

The shared `base.md` has a §Summary section that gets read on chained dispatch. This re-injects core behavioral rules at each phase transition without the cost of loading the full file every time.

## Recovery

When context rot is already happening, the user can reset the agent's behavioral state:

### Recommended: Start a New Session

The most reliable fix for context rot is starting a fresh chat session. Context rot cannot survive a session boundary — all instruction drift resets.

Start the new session with:
- **`/aidlc resume`** — re-reads the manifest, presents current state, continues from the correct point
- **`/aidlc status`** — shows the full progress dashboard without advancing

All artifacts on disk are preserved. No work is lost. The agent reloads all skill instructions fresh and respects checkpoints again.

**Rule of thumb**: If a workflow spans more than 3-4 phases in one session, consider starting a new session before the next phase. This is especially important for complex projects with incremental mode (multiple units).

### Quick Recovery (Same Session)

Say any of these:
- **"status"** — forces the orchestrator to re-read manifest and present current state
- **"resume"** — full state reload: manifest → routing → status display → ask what to do next
- **"help"** — presents available commands and current position

These commands trigger a re-read of the manifest and SKILL.md, effectively resetting the agent to correct behavior.

### Full Recovery

If the agent is severely drifted (ignoring commands, writing arbitrary code):

1. **Start a new session** — context rot cannot survive a session boundary
2. Say **"resume"** — the orchestrator reads the manifest and picks up from the correct state
3. All artifacts on disk are preserved — no work is lost

### Manual Intervention

If the agent produces artifacts that should not exist (e.g., filled decision files, generated design without approval):

1. Delete the incorrect files from disk
2. Say **"repair"** — rebuilds the manifest from what actually exists on disk
3. Continue from the correct state

## Limitations

No mitigation strategy completely eliminates context rot. The fundamental issue is that instruction following degrades as context grows — this is a property of current LLM architectures, not a bug in the workflow.

What we can do:
- **Reduce** the probability of drift (hooks, anchors, identity resets)
- **Detect** when it's happening (user notices skipped checkpoints)
- **Recover** quickly without losing work (resume, repair, new session)

What we cannot do:
- **Prevent** it structurally in all cases without external script dependencies
- **Guarantee** the agent will always follow hooks (the agent-type hook is still instruction-based)

The most reliable mitigation remains: **shorter sessions**. If you're running a complex workflow (5+ phases, incremental mode with multiple units), consider breaking it across multiple sessions rather than doing everything in one long conversation.

## Platform Comparison

| Mechanism | Kiro | Claude Code |
|---|---|---|
| Steering file anchors (always loaded) | ✅ `aidlc-workflow.md` with `inclusion: always` | ✅ `CLAUDE.md` (auto-loaded) |
| Skill handoff identity reset | ✅ | ✅ |
| Session-based recovery | ✅ | ✅ |
| Manifest-based resume | ✅ | ✅ |
| PreToolUse hooks (optional, for stricter enforcement) | ✅ Available if needed | ✅ Available if needed |
