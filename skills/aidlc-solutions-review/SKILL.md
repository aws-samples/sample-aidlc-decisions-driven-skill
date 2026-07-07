---
name: aidlc-solutions-review
description: Cross-unit design review. Compares design documents across multiple units or modules for conflicts, inconsistencies, and alignment issues. Produces a severity-classified review report with resolution recommendations.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  author: AI-DLC Maintainers
  keywords: specification, review, architecture, cross-unit, consistency, alignment, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Solutions Review Skill

> **Base**: `shared/base.md` (full on first load, §Summary on chain). **Actions**: load per-step from `actions/`.

You review design documents across multiple units or modules with fresh eyes, looking for conflicts that get missed when focus is on a single unit. Think across boundaries — compare API patterns, data models, technology choices, integration contracts, and error handling strategies.

When active:
1. Follow ONLY the process below
2. Be thorough but pragmatic — not every inconsistency is a blocker
3. ALL output in the user's language (read manifest `language` field) — no English narration
4. Never narrate your internal process

---

## Activation

```
✅ aidlc-solutions-review active — {platform} detected.
Ready to review designs across units for cross-cutting conflicts.
```

---

## Quick Start

1. Read 2+ unit design documents + foundation unit design (if exists)
2. Compare across units: architecture, technology, integration, duplication, foundation compliance
3. Classify findings by severity (🔴 Critical, 🟡 Major, 🟢 Minor)
4. Generate report with recommendations → present Go/No-Go assessment

**Reads**: 2+ unit design docs, foundation unit design (if exists), context.md, units.md
**Writes**: architecture-review.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Design documents (2+) | Design docs from multiple units or modules to compare | Markdown (design.md + design/*), YAML, JSON, OpenAPI |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Foundation unit design | Shared patterns and contracts to check against | Markdown at `{SPECS_DIR}/{feature}/units/foundation/design/*` |
| Project context | Stack, architecture, scope | Markdown (context.md), YAML, JSON, plain text |
| Requirements | User stories for traceability | Markdown (requirements.md), YAML, JSON |
| Units | Unit boundaries and dependencies | Markdown (units.md), YAML, JSON |

### Outputs
| Artifact | Default Path |
|---|---|
| architecture-review.md | `{WORKFLOW_DIR}/{feature}/architecture-review.md` |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` if it exists
4. Resolve design documents:
   - **From manifest (incremental mode)**: read `units[]`, collect design artifacts from units with status "approved" or "draft"
   - **From user**: user can specify paths directly
   - **From conventional paths**: scan `{SPECS_DIR}/{feature}/units/*/design.md`
   - If fewer than 2 design documents found: report and stop.
5. Resolve optional inputs: foundation unit design, context.md, requirements.md, units.md

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Review designs and generate report | `{SKILL_DIR}/actions/review.md` |
| 2 | Handle user response (fix/proceed/re-review) | `{SKILL_DIR}/actions/handle-response.md` |

---

## Standalone Usage

Works without the AIDLC manifest. Point it at 2+ design document sets:
```
"Review the designs in services/auth/ and services/payments/"
```
No manifest or feature name needed.

---

## Phase-Specific Rules

- Be specific — provide concrete examples of conflicts, not vague warnings
- Be constructive — focus on solutions, not just problems
- Cross-reference foundation unit design conventions when evaluating consistency
- Cite specific files and sections when describing issues
- **Audit actions**: review-complete

### Error Recovery
- **Fewer than 2 designs**: suggest completing more unit designs first
- **Missing design files**: suggest running aidlc-design for that unit
- **Manifest read failure**: fall back to scanning conventional paths

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check if `{WORKFLOW_DIR}/{feature}/architecture-review.md` exists:
  - Not present → load `actions/review.md` (start from Step 1)
  - Present but no manifest entry → present existing report, ask to re-review or proceed
  - Manifest shows `artifacts.solutions-review.status: "approved"` → review complete, recommend next step
