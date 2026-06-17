# Action: rollback

When user says "go back to [phase]", "redo [phase]", or "start over from [phase]":

1. Identify the target phase from user's request
2. Read manifest to determine what exists after that phase
3. Mark all artifacts produced AFTER the target phase as `outdated` in the manifest:
   - If rolling back to requirements: mark units, foundation, design, tasks as `outdated`
   - If rolling back to design: mark tasks as `outdated`
   - etc.
4. Remove phases after the target from `state.sharedPhases` (for shared phases) or `units[{unit}].completedPhases` (for unit phases)
5. Present what was invalidated:

```
📍 Rollback to {phase}

Marked as outdated:
- {artifact 1} (produced by {skill})
- {artifact 2} (produced by {skill})

These artifacts still exist on disk but are marked stale. Downstream skills will warn before using them.

👉 Continue from {phase}?
```

**STOP and wait.** On "yes" / "go" / "continue": dispatch the target phase skill.

**Note**: Rollback does NOT delete files — it marks them `outdated` in the manifest. The dispatched skill will overwrite the outdated artifacts with fresh ones.
