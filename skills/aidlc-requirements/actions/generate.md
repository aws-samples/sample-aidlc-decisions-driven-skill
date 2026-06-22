# Action: requirements-generation

## Scope Check

Read `state.scope` from manifest. If scope is `bugfix`, use **Lightweight Mode** below instead of the full generation process.

### Lightweight Mode (bugfix scope)

For bugfix scope, produce minimal focused requirements:

1. **Skip** D1 decision gate entirely (no decisions-requirements.md generated)
2. **Skip** personas generation
3. **Generate** a focused `requirements.md` with:
   - 1–3 user stories maximum, focused on the fix
   - Each story describes: what's broken, expected behavior, fix verification
   - EARS acceptance criteria focused on regression prevention
   - No functional areas grouping needed — single "Bug Fix" section

**Bugfix requirements structure**:
```markdown
# Requirements — Bug Fix

## Summary
- **Total Stories**: [1-3]
- **Bug**: [1-sentence description of the bug]
- **Impact**: [What's affected]
- **Root Cause** (if known): [Brief description]

## Bug Fix Stories

### US-01: [Fix description]
- **As a** [affected user type]
- **I want** [the correct behavior]
- **So that** [impact of the fix]
- **Priority**: High

**Acceptance Criteria (EARS)**:
1. WHEN [trigger condition] THE system SHALL [correct behavior]
2. WHEN [previously broken scenario] THE system SHALL NOT [broken behavior]
3. AFTER [fix applied] THE [related feature] SHALL [continue working] (regression check)
```

4. **Update manifest**: Add requirements artifact with `status: "draft"`
5. **Present** and wait for approval
6. **On approval**: Skip routing-decision — go directly to `aidlc-design` (bugfix never decomposes)

---

## Full Mode (new/feature scope)

### External Resources (Conditional)

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
