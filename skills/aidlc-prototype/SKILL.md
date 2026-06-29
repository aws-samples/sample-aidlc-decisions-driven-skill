---
name: aidlc-prototype
description: Build a throwaway spike to validate requirements. Demonstrates core user flows with minimal code — no architecture, no tests, no production concerns.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, prototype, spike, validation, throwaway, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Prototype Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You build throwaway spikes to validate requirements. Write the minimum code needed to demonstrate core user flows — no architecture, no tests, no production concerns. Hardcoded data is fine. Ugly UI is fine. The goal is learning, not shipping.

When active:
1. Follow ONLY the process below
2. WAIT for user confirmation at each checkpoint
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-prototype v1.0.0 active — {platform} detected.
Ready to build a throwaway prototype to validate requirements.
```

Then proceed to initialization.

---

## Quick Start

1. Select top 3-5 highest-priority stories → present scope → wait for confirmation
2. Build minimal throwaway code in `.aidlc/prototype/{feature}/` — no architecture, no tests, hardcoded data
3. Report discoveries and suggested requirement changes
4. User chooses: update requirements / proceed to design / discard prototype

**Reads**: requirements.md (or inline stories), design resources
**Writes**: `.aidlc/prototype/{feature}/` (throwaway code + README)

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| User stories with priorities | What to prototype — stories describing core user experience | Markdown (requirements.md), YAML, JSON, CSV, plain text, inline |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Design resources | Figma links, design system docs, wireframes | Via MCP, URLs, file paths |

### Outputs
| Artifact | Default Path | Description |
|---|---|---|
| Prototype code | `.aidlc/prototype/{feature}/` | Throwaway code demonstrating core flows |
| README.md | `.aidlc/prototype/{feature}/README.md` | How to run, what's demonstrated, what's faked |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest if it exists — use artifact paths to locate requirements
4. Resolve requirements input:
   - Manifest artifact `requirements` → read files from `{SPECS_DIR}/{feature}/`
   - Conventional path `{SPECS_DIR}/{feature}/requirements.md`
   - User-provided path or inline content
   - If not found: ask user for stories (inline is fine)

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Build prototype (scope → build → report → handle response) | `{SKILL_DIR}/actions/build.md` |

---

## Skill Handoff

**Next skill**: `aidlc-context` (when user says "start context" or "done, start context").

---

## Phase-Specific Rules

### Manifest Rules
- Do NOT update `state.sharedPhases` or `units[].phase` / `units[].completedPhases` — the prototype is a side-quest, not a workflow phase.
- Do NOT create decision gates or task files for the prototype.

### Prototype Boundaries
- Keep it minimal — if it takes more than 15-20 minutes of AI time, you're over-engineering.
- Prototype code is explicitly throwaway — it is NOT carried forward to implementation.
- ALL prototype code goes to `.aidlc/prototype/{feature}/` — never pollute the workspace.
- Do NOT create design documents, decision gates, or tasks for the prototype.
