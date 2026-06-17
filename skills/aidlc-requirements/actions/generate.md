# Action: requirements-generation

## External Resources (Conditional)

If `{STEERING_DIR}/resources.md` lists available resources:
- **Design tool**: Use MCP to read screens, user flows → extract user journeys and acceptance criteria
- **Design docs/wireframes**: Read files → identify UI requirements
- **API specs**: Read OpenAPI/GraphQL → identify integration stories and data entities
- **Documentation**: Use web search/fetch → gather domain context
- Cite external sources in generated stories

## Personas (Conditional)

Generate IF D1 indicated "Yes" for personas or multiple user types.
Read `{ASSETS_DIR}/persona.md` for output structure.
Generate `{SPECS_DIR}/{feature}/personas.md`.

## Requirements

Derive from D1 decisions + context + personas (if exists).
Read decisions from manifest `decisions.requirements` section. Fall back to reading `## Decisions Summary` from the decisions file if manifest section is missing.
Read `{ASSETS_DIR}/requirements.md` for output structure.
Generate `{SPECS_DIR}/{feature}/requirements.md`.

## Validate Output

- ✅ All D1 scope features have stories
- ✅ All user types represented
- ✅ All stories have EARS acceptance criteria
- ✅ Stories organized by functional area
- ✅ Priorities assigned

## Update Steering

Update `{STEERING_DIR}/product.md`:
- **Target Users**: Merge new user types alongside existing. Do not remove previous.
- **Key Features**: Merge new functional areas alongside existing. Do not remove previous.
- Read current file first, preserve all existing sections.

## Update Manifest

- Add `requirements` phase entry: `status: "draft"`, `timestamp`, `files: [requirements.md, personas.md]`
- Update `steering.updatedBy.product` to include `requirements`

## Present Results

```
📍 Requirements

[Summary]

- **Total Stories**: [X] across [Y] functional areas
- **Priority**: [X] High, [Y] Medium, [Z] Low
- **User Types**: [list]
- **Personas**: [Generated / Skipped]

Artifact at `{SPECS_DIR}/{feature}/requirements.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to routing decision
- ✏️ "change [what]" — request edits
```

**STOP and wait for approval.**

On approval: update manifest (`artifacts.requirements.status` → `"approved"`, add `"requirements"` to `state.sharedPhases`). Store team size in `context-summary.teamSize`. Append audit entry. Then auto-continue to routing-decision.

---

# Action: routing-decision

After requirements are approved, analyze complexity and project context to recommend next phase.

## Analyze

- Count: total stories, distinct domains, user types, integrations
- Extract from context.md Summary: project type, impact, architecture

## Routing Logic

| Context | Recommend Design | Recommend Decomposition |
|---|---|---|
| Brownfield + extends existing | Default | 10+ stories AND 3+ domains AND cross-cutting |
| Brownfield + cross-cutting | Below all thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |
| Greenfield | Below all thresholds | 5+ stories OR 2+ domains OR 3+ user types OR 3+ integrations |

## Present

```
📍 Requirements Complete — What's Next?

Your project has [X stories] across [Y areas] with [Z user types] and [W integrations].

👉 Recommendation: [Decompose into units / Go straight to design]
Reason: [brief explanation]

---
🔲 **Your turn**:
- ✅ "proceed" — follow recommendation
- 🔀 "go to [design/units]" — override
- 🧪 "prototype" — throwaway prototype first
```

**STOP and wait.**
