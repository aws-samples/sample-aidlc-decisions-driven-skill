# Action: status

## Status Display

When user asks for status, present:

```
📍 Workflow Status: {feature}

Shared Phases    Status     Artifact
──────────────   ─────────  ────────
Context          ✅ Done    context.md
Requirements     ✅ Done    requirements.md (X stories)
Decomposition    ✅ Done    units.md (Y units)

Mode: {Incremental / Comprehensive / Not yet decided}

{If incremental:}
Units:
  ✅ foundation-infra — completed
  🔄 auth — implement (8/12 tasks, standard mode)
  🔄 notifications — design (draft)
  ⬜ payments — not started

{If incremental:}
Overall: {X}% complete ({completed}/{total} units done{, Y tasks completed across active units})

{If comprehensive:}
Design           🔄 Draft   design.md (unapproved)
Tasks            ⬜ Pending  —
Implementation   ⬜ Pending  —

👉 Next: {recommendation}
```

Status icons:
- ✅ Done — artifact exists with status `approved`
- 🔄 Draft — artifact exists with status `draft` (needs approval)
- ⚠️ Outdated — artifact exists with status `outdated` (upstream changed)
- ⬜ Pending — no artifact yet

For story/unit counts, read the actual files to count items.

---

## Workflow Diagram Progress

After reading manifest state (on `resume`, `status`, or `next`), update the `## Recommended Workflow` diagram in `{SPECS_DIR}/{feature}/context.md` to reflect current progress.

**Update rules**:
1. Read `{SPECS_DIR}/{feature}/context.md`
2. Find the `## Recommended Workflow` section containing the ASCII art diagram
3. For each phase box in the diagram, update based on manifest state:
   - Phase in `state.sharedPhases` → append ` ✅` to the box label (e.g., `│ Requirements ✅ │`)
   - Phase not started → leave as-is (no icon)
4. For incremental mode unit boxes: update each unit box with its status from `units[]`
   - `completed` → `✅`, `in-progress` → `🔄`, `not-started` → no icon
5. Write the updated diagram back to `context.md`

**Example** — after requirements approved, design in progress:

```
       ┌─────────────┐
       │  Context ✅  │
       └──────┬──────┘
              ▼
       ┌────────────────┐
       │ Requirements ✅ │
       └──────┬─────────┘
              ▼
       ┌────────────┐
       │ Design 🔄  │
       └────┬───────┘
            ▼
       ┌─────────┐
       │  Tasks  │
       └────┬────┘
            ▼
       ┌───────────┐
       │ Implement │
       └─────┬─────┘
             ▼
       ┌─────────────┐
       │ Code Review │
       └─────────────┘
```

**Silent operation** — do not mention the diagram update to the user. It happens automatically as part of state reading.
