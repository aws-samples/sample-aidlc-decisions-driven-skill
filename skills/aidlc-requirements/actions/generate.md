# Action: requirements-generation

## Scope Check

Read `state.scope`. If `bugfix` → use Lightweight Mode. Otherwise → Full Mode.

### Lightweight Mode (bugfix)

1. Skip D1 gate, skip personas
2. Generate focused `requirements.md` (1-3 stories): what's broken, expected behavior, regression check
3. EARS criteria focused on fix verification
4. Structure: `# Requirements — Bug Fix` → Summary (bug, impact, root cause) → Stories with EARS
5. Update manifest: `artifacts.requirements` → `status:"draft"`
6. Present → STOP → on approval: skip routing, go directly to `aidlc-design`

---

## Full Mode (new/feature)

### External Resources

If `{STEERING}/resources.md` lists resources:
- Design tool MCP → extract user journeys/acceptance criteria
- Wireframes/docs → UI requirements
- API specs → integration stories + entities
- Web search → domain context
- Cite sources in stories

### Personas (conditional)

Generate IF D1=Yes for personas or multiple user types.
Template: `{ASSETS}/persona.md` → write `{SPECS}/{feature}/personas.md`

### Requirements

Derive from D1 decisions + context + personas.
Read D1 from manifest `decisions.requirements` (fallback: Decisions Summary section).
Template: `{ASSETS}/requirements.md` → write `{SPECS}/{feature}/requirements.md`

### Validate

- All D1 scope features have stories
- All user types represented
- All stories have EARS acceptance criteria
- Organized by functional area, priorities assigned

### Update Steering

`product.md`: merge new user types + features alongside existing. Preserve prior content.

### Update Manifest

`artifacts.requirements` → `status:"draft"`, files: [requirements.md, personas.md]
`steering.updatedBy.product` += `requirements`

### Present Results

```
📍 Requirements

[Summary]

- **Total Stories**: [X] across [Y] functional areas
- **Priority**: [X] High, [Y] Medium, [Z] Low
- **User Types**: [list]
- **Personas**: [Generated / Skipped]

Artifact at `{SPECS}/{feature}/requirements.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to routing decision
- ✏️ "change [what]" — request edits
```

**STOP and wait.**

On approval: `status:"approved"`, add `"requirements"` to `sharedPhases`, store `teamSize`. Audit. Auto-continue to routing-decision.

---

# Action: routing-decision

After requirements approved, recommend next phase.

## Analyze

Count: stories, distinct domains, user types, integrations.
Read context.md Summary: project type, impact, architecture.

## Routing Logic

| Context | → Design | → Decomposition |
|---|---|---|
| Brownfield + extends existing | Default | 10+ stories AND 3+ domains AND cross-cutting |
| Brownfield + cross-cutting | Below all thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |
| Greenfield | Below all thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |

## Present

```
📍 Requirements Complete — What's Next?

Your project has [X stories] across [Y areas] with [Z user types] and [W integrations].

👉 Recommendation: [Decompose into units / Go straight to design]
Reason: [brief]

---
🔲 **Your turn**:
- ✅ "proceed" — follow recommendation
- 🔀 "go to [design/units]" — override
- 🧪 "prototype" — throwaway prototype first
```

**STOP and wait.**
