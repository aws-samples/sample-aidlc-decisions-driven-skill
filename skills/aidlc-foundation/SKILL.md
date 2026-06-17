---
name: aidlc-foundation
description: Define shared conventions, contracts, and infrastructure for incremental multi-unit projects.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, foundation, conventions, infrastructure, contracts, incremental, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Foundation Skill

> **Shared base**: Load `../aidlc/shared/base.md` for environment detection, feature resolution, manifest operations, behavioral rules, audit format, and skill handoff protocol.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You establish the shared foundation that keeps parallel workstreams aligned. Define repository structure, authentication, error handling, communication patterns, database strategy, and infrastructure units. Runs in incremental mode after units are defined.

When active:
1. Follow ONLY the process below
2. WAIT for user approval after each step
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-foundation v1.0.0 active — {platform} detected.
Ready to define shared conventions and infrastructure for your units.
```

---

## Quick Start

1. Generate DF decision gate → user fills answers (or "use recommendations")
2. Validate DF for conflicts → resolve if any
3. Generate foundation spec + add infrastructure units
4. Update steering/tech.md and steering/structure.md
5. Present results → wait for approval
6. On approval → present unit selection → hand off to design

**Reads**: context.md (Summary), requirements.md, units.md
**Writes**: decisions-foundation.md, foundation.md, units.md (updated), steering/tech.md, steering/structure.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Project context | Stack, architecture, scope | Markdown (context.md), YAML, JSON, plain text, inline |
| User stories | Requirements for scoping | Markdown (requirements.md), YAML, JSON, CSV, plain text |
| Units | Decomposition with boundaries and dependencies | Markdown (units.md), YAML, JSON |

### Outputs
| Artifact | Default Path |
|---|---|
| decisions-foundation.md | `{WORKFLOW_DIR}/{feature}/decisions-foundation.md` |
| foundation.md | `{SPECS_DIR}/{feature}/foundation.md` |
| units.md (update) | `{SPECS_DIR}/{feature}/units.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve inputs:
   - Context — **read only `## Summary` section**
   - Requirements — **read only `## Summary` section**
   - Units — read full content (needed for unit details)
5. **Partial write detection**: If manifest shows foundation status = `"approved"` but file missing → set `"partial"`, re-generate.

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Generate DF decisions + validate | `{SKILL_DIR}/actions/decision-gate.md` |
| 2 | Generate foundation + unit selection | `{SKILL_DIR}/actions/generate.md` |
| 3 | Edit (if user requests changes) | `{SKILL_DIR}/actions/edit.md` |

---

## Skill Handoff

**Next skill**: `aidlc-design` (on unit selection after foundation approved).

---

## Phase-Specific Rules

- **Audit actions**: decision-gate, validation, generation, approval, edit.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check `artifacts.foundation.status`:
  - Not present → load `actions/decision-gate.md` (start from DF)
  - `"draft"` → load `actions/generate.md` (decisions done, generate foundation)
  - `"approved"` → load `actions/generate.md` unit selection section
