# Action: quick-path

When user says "quick", "quick mode", "simple feature", or the orchestrator detects a simple brownfield feature (≤5 stories, single domain, extends existing):

The quick path collapses context + requirements + design + tasks into a single conversational pass. No decision gates, no separate files per phase — one combined spec.

## Process

1. **Gather context** (inline, no separate file):
   - Scan workspace briefly — detect stack, architecture, key patterns
   - Ask: "What feature are you building?" + "Which areas of the codebase does it touch?"

2. **Generate requirements** (inline, no decision gate):
   - Generate 3-8 user stories with EARS acceptance criteria directly from the conversation
   - Present stories inline — no separate requirements.md

3. **Generate design** (inline, no decision gate):
   - Use detected stack (brownfield) or ask for stack preference (greenfield)
   - Generate a compact design: components, data model changes, API endpoints, implementation plan
   - Present inline

4. **Generate tasks** (inline, no decision gate):
   - Break design into sequenced tasks with Kiro checkbox format
   - Present inline

5. **Create combined spec**:
   - Write everything to a single file: `{SPECS_DIR}/{feature}/spec.md` containing: Summary, Stories, Design, Tasks
   - Create manifest with `state.status: "active"`, `state.sharedPhases: [context, requirements, design, tasks]`, `state.quickPath: true`
   - Mark all phases as approved (user approved the combined spec)

6. **Present for approval**:

```
📍 Quick Spec — {feature}

- **Stories**: [X] across [Y] areas
- **Components**: [Z] designed
- **Tasks**: [W] sequenced

Artifact at `{SPECS_DIR}/{feature}/spec.md`.

---
🔲 **Your turn**:
- ✅ "implement" — start building (standard mode)
- ✏️ "change [what]" — request edits
- 🔀 "full workflow" — switch to the full phase-by-phase workflow
```

**STOP and wait.**

On "implement": dispatch `aidlc-implement` with the tasks from spec.md.
On "full workflow": the combined spec serves as a starting point — dispatch `aidlc-context` which will enrich it.

---

## When to Suggest Quick Path

The orchestrator should suggest quick path when:
- User says "start" AND context scan reveals: brownfield project, feature extends existing module, estimated ≤5 stories
- Present: "This looks like a straightforward feature. Want to use quick mode (single-pass spec) or the full workflow?"
