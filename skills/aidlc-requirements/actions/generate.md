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

### Parity Mode (rewrite scope only)

Derivation is inverted: stories come FROM the extracted baseline, not from invention. D1 answers set the parity level; the baseline sets the content.

1. Read `.aidlc/reverse-engineer/parity/rules.md` in full, `features.md`, and the Totals + section headings of `parity/screens.md` and `parity/endpoints.md`. Large systems: process one module at a time, write stories per module, release context (same discipline as reverse-engineer Phase 2).
2. **Every story cites its origin**: `**Legacy-Ref**: BR-*, SCR-*, OP-*` (one or more IDs, or `file:line` for facts outside the registers).
3. **Every BR-*** appears in at least one story's acceptance criteria — the EARS restatement of the rule, behavior-identical.
4. A story with no legacy origin → mark `[NEW — not in legacy]` in the story title.
5. Legacy behavior NOT carried forward → entry in the deviation register, never a silent omission.
6. Generate `{SPECS}/{feature}/deviations.md` — the deviation register:
   `| ID (DEV-NNN) | Type (NEW / DROPPED / CHANGED) | What | Legacy-Ref | Reason | Approved |`
7. requirements.md gains a `## Parity Coverage` section: BR-* → story IDs, SCR-* → story IDs, OP-* → story IDs, plus a counts row (covered / baseline total / deviations).

### Validate

- All D1 scope features have stories
- All user types represented
- All stories have EARS acceptance criteria
- Organized by functional area, priorities assigned

**Parity mode (rewrite) — FAIL conditions, fix before presenting**:
- FAIL if any BR-* has zero story coverage and no deviation entry
- FAIL if any SCR-* or OP-* is unaccounted for (no story, no deviation entry)
- FAIL if any story lacks a `Legacy-Ref` and is not marked `[NEW — not in legacy]`
- FAIL if Parity Coverage counts ≠ baseline Totals − DROPPED deviations

### Update Blueprints

`{BLUEPRINTS_DIR}/product.md`: merge new user types + features alongside existing. Preserve prior content.

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
{Rewrite scope — add:}
- **Parity coverage**: [X]/[N] rules, [Y]/[P] screens, [Z]/[S] operations
- **Deviations**: [D] total — [a] NEW, [b] DROPPED, [c] CHANGED (`deviations.md`)

Artifact at `{SPECS}/{feature}/requirements.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to routing decision
- ✏️ "change [what]" — request edits
{Rewrite scope: '- 📋 "show deviations" — review the deviation register before approving'}
```

**STOP and wait.**

On approval: `status:"approved"`, add `"requirements"` to `sharedPhases`, store `teamSize` in `context-summary.teamSize`. **Rewrite scope**: approval covers the deviation register too — set every register row's Approved column, audit "requirements + {D} deviations approved". Audit. Auto-continue to routing-decision.

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
