---
name: aidlc-decomposition
description: Decompose requirements into units of work with DDD concepts. Define system boundaries, dependencies, and development sequence.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, decomposition, units, DDD, bounded-context, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Decomposition Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You break requirements into manageable, independently deliverable units of work using DDD concepts. Define system boundaries, dependencies, and development sequence.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration
4. Do NOT make technology stack decisions — that's the design phase's job
5. For upstream artifacts, read ONLY `## Summary` first

---

## Activation

```
✅ aidlc-decomposition v1.0.0 active — {platform} detected.
Ready to decompose requirements into units of work.
```

---

## Quick Start

1. Generate D2 decision gate → user fills answers (or "use recommendations")
2. Validate D2 for conflicts → resolve if any
3. Generate units with boundaries, dependencies, and story assignments
4. Present results → wait for approval
5. On approval → choose delivery mode (incremental / comprehensive)

**Reads**: context.md (Summary), requirements.md, personas.md
**Writes**: decisions-units.md, units.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | What exists, stack, scope | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories with priorities | Requirements from previous phase | Markdown (requirements.md), YAML, JSON, CSV, plain text |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Personas | User types and characteristics | Markdown (personas.md), YAML, JSON |
| Reverse-engineer analysis | Existing module boundaries | `.aidlc/reverse-engineer/modules.md` |

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-units.md | `{WORKFLOW_DIR}/{feature}/decisions-units.md` |
| units.md | `{SPECS_DIR}/{feature}/units.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve project context and requirements inputs
5. Resolve personas input (skip silently if not found)

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Generate D2 decisions + validate | `{SKILL_DIR}/actions/decision-gate.md` |
| 2 | Generate units + mode selection | `{SKILL_DIR}/actions/generate.md` |
| 3 | Edit (if user requests changes) | `{SKILL_DIR}/actions/edit.md` |

---

## References

For decomposition strategies, DDD concepts, sizing guidance, read `{SKILL_DIR}/references/decomposition-strategies.md` when generating.

---

## Skill Handoff

Based on delivery mode choice:
- **Incremental** → unit dashboard, then `aidlc-design` for selected unit
- **Comprehensive** → `aidlc-design`

---

## Phase-Specific Rules

- **Audit actions**: decision-gate, validation, generation, approval, edit.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `artifacts.decomposition.status`:
  - Not present → load `actions/decision-gate.md` (start from D2)
  - `"draft"` → load `actions/generate.md` (decisions done, generate units)
  - `"approved"` → load `actions/generate.md` mode selection section
- Check `state.mode` — if already set, proceed to unit selection or next skill
