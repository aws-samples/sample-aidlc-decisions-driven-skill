---
name: aidlc-solutions-review
description: Cross-unit design review. Compares design documents across multiple units or modules for conflicts, inconsistencies, and alignment issues. Produces a severity-classified review report with resolution recommendations.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, review, architecture, cross-unit, consistency, alignment, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Solutions Review Skill

> **Shared base**: Load `../aidlc/shared/base.md` for environment detection, feature resolution, manifest operations, behavioral rules, audit format, and skill handoff protocol. This file contains only phase-specific instructions.

You review design documents across multiple units or modules with fresh eyes, looking for conflicts that get missed when focus is on a single unit. Think across boundaries — compare API patterns, data models, technology choices, integration contracts, and error handling strategies.

When active:
1. Follow ONLY the process below
2. Be thorough but pragmatic — not every inconsistency is a blocker
3. Never narrate your internal process

---

## Activation

```
✅ aidlc-solutions-review v1.0.0 active — {platform} detected.
Ready to review designs across units for cross-cutting conflicts.
```

---

## Quick Start

1. Read 2+ unit design documents + foundation conventions
2. Compare across units: architecture, technology, integration, duplication, foundation compliance
3. Classify findings by severity (🔴 Critical, 🟡 Major, 🟢 Minor)
4. Generate report with recommendations → present Go/No-Go assessment

**Reads**: 2+ unit design docs, foundation.md, context.md, units.md
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
| Foundation conventions | Shared patterns and contracts to check against | Markdown (foundation.md), YAML, JSON |
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
   - **From manifest (incremental mode)**: read `units[]` array, collect design artifacts from all units with status "approved" or "draft"
   - **From user**: user can specify paths directly — "review designs in folder-a/ and folder-b/"
   - **From conventional paths**: scan `{SPECS_DIR}/{feature}/units/*/design.md` for unit design folders
   - If fewer than 2 design documents found: report "Need at least 2 unit designs to compare. Only found [X]." and stop.
5. Resolve optional inputs: foundation.md, context.md, requirements.md, units.md from manifest or conventional paths

---

## Process

### Action: review-designs

#### Step 1: Gather Documents

For each unit/module with design documents:
- Read `design.md` (or compact design if single-file)
- Read `design/components.md` — component breakdown
- Read `design/data-model.md` — entities and schemas
- Read `design/api-spec.md` — endpoints and contracts
- Read `design/integration.md` — external services and inter-unit comms
- Read `design/implementation.md` — directory structure and conventions

Also read:
- `context.md` — for project-wide context
- `requirements.md` — for traceability
- `units.md` — for boundary definitions and dependency contracts
- `foundation.md` — for shared conventions baseline (if exists)

Extract from each unit: key decisions, technologies, API patterns, data models, error handling, auth approach, integration points.

#### Step 2: Identify Conflicts

Compare across all units in these categories:

**Architectural Conflicts**:
- Different API patterns (one unit uses REST, another GraphQL)
- Conflicting data models (same entity defined differently in two units)
- Inconsistent error handling (different error formats or codes)
- Different auth mechanisms (one uses JWT, another session)
- Conflicting middleware or interceptor patterns

**Technology Conflicts**:
- Incompatible library versions (unit A uses Express 4, unit B uses Express 5)
- Conflicting dependencies (libraries that don't work together)
- Different databases where shared was expected
- Incompatible runtime requirements

**Integration Conflicts**:
- Missing integration points (unit A expects an API from unit B that doesn't exist)
- Circular dependencies between units
- Undefined contracts (unit A publishes events that no one consumes, or vice versa)
- Unclear boundaries (both units claim ownership of the same functionality)
- Mismatched request/response schemas between producer and consumer

**Duplication**:
- Overlapping responsibilities (both units implement user validation)
- Redundant implementations (same utility code in multiple units)
- Duplicate data models (same entity maintained in two places)

**Foundation Compliance** (if foundation.md exists):
- Deviations from agreed conventions (naming, error format, auth approach)
- Missing shared patterns (unit doesn't use the agreed error handling)
- Inconsistent with repo structure conventions

#### Step 3: Analyze Impact

For each identified conflict:
- Which units are affected
- Severity classification:
  - 🔴 **Critical**: Blocks implementation or causes runtime failures. Must resolve before proceeding.
  - 🟡 **Major**: Causes inconsistency or maintenance burden. Should resolve before implementation.
  - 🟢 **Minor**: Cosmetic or stylistic inconsistency. Can resolve during implementation.

Finding IDs use the `SR-` namespace prefix (e.g., `SR-CR-1`, `SR-MJ-1`, `SR-MN-1`) to distinguish from code-review findings.
- Downstream effects (what breaks if not resolved)
- Whether it affects the integration contracts between units

#### Step 4: Recommend Solutions

For each conflict, provide:
- Clear description of the issue
- Which units need to change
- Recommended resolution (specific: "Unit A should change endpoint X to match Unit B's contract")
- Alternatives if applicable
- Effort estimate (trivial / small / medium / large)

#### Step 5: Generate Report

Write `{WORKFLOW_DIR}/{feature}/architecture-review.md`:

```markdown
# Solutions Review — {feature}

## Review Summary

- **Date**: {ISO timestamp}
- **Units Reviewed**: {list of unit names}
- **Alignment Status**: [Aligned / Partially Aligned / Significant Conflicts]
- **Issues**: {X} critical, {Y} major, {Z} minor

## Findings

### 🔴 Critical Issues

#### SR-CR-1: {Issue Title}
**Affected Units**: {unit A}, {unit B}
**Category**: {Architectural / Technology / Integration / Duplication}
**Description**: {What's wrong}
**Impact**: {What breaks if not resolved}
**Recommendation**: {Specific fix}
**Alternatives**: {Other options}
**Effort**: {trivial / small / medium / large}

---

### 🟡 Major Issues

#### SR-MJ-1: {Issue Title}
[Same structure as critical]

---

### 🟢 Minor Issues

#### SR-MN-1: {Issue Title}
[Same structure]

---

## Recommendations

### Immediate Actions (Before Implementation)
1. {Action — resolve critical issue SR-CR-1}
2. {Action — resolve critical issue SR-CR-2}

### Design Refinements (Should Do)
1. {Refinement — address major issue SR-MJ-1}

### Consolidation Opportunities (Nice to Have)
1. {Opportunity — address minor issue SR-MN-1}

## Conclusion

**Go/No-Go**: {Go — no critical issues / Conditional Go — resolve critical issues first / No-Go — fundamental misalignment, redesign needed}

{If Conditional Go or No-Go: specific blockers that must be resolved}
```

#### Step 6: Present Results

```
📍 Solutions Review Complete

- **Units Reviewed**: {list}
- **Alignment**: {Aligned / Partially Aligned / Significant Conflicts}
- **Critical**: {X} issues
- **Major**: {Y} issues
- **Minor**: {Z} issues
- **Go/No-Go**: {recommendation}

Report at `{WORKFLOW_DIR}/{feature}/architecture-review.md`.

{If critical issues exist:}
⚠️ Critical issues must be resolved before implementation:
- SR-CR-1: {brief description} — affects {units}
- SR-CR-2: {brief description} — affects {units}

---
🔲 **Your turn**:
- ✏️ "fix SR-CR-1" — update the affected unit's design (activates aidlc-design for that unit)
- ✅ "proceed" — accept current designs, move to tasks
- 🔍 "re-review" — run the review again after fixes
```

**STOP and wait.**

### Action: handle-response

- **"fix [issue]"**: Identify which unit's design needs to change. Recommend activating `aidlc-design` for that unit with the specific edit. Auto-continue: read `{PLATFORM_DIR}/skills/aidlc-design/SKILL.md` and begin the design-edit action for the affected unit.
- **"proceed"**: Update manifest — add `artifacts.solutions-review` entry with `status: "approved"`, `timestamp`, `files: [architecture-review.md]`. Recommend next step based on manifest state (typically: activate `aidlc-tasks` for the next unit, or select next unit via `aidlc-foundation`).
- **"re-review"**: Re-run the review from Step 1 with updated design documents.

---

## Standalone Usage (Outside AIDLC Workflow)

This skill works without the AIDLC manifest or workflow. You can use it to review any set of design documents:

```
"Review the designs in services/auth/ and services/payments/"
```

The skill will:
1. Read design documents from the specified paths
2. Run the full comparison
3. Generate a review report

No manifest needed. No feature name needed. Just point it at 2+ design document sets.

---

## Behavioral Rules

### Rules
- Be thorough — deeply analyze each design
- Be specific — provide concrete examples of conflicts, not vague warnings
- Be constructive — focus on solutions, not just problems
- Be pragmatic — consider trade-offs, not every inconsistency is a blocker
- Cross-reference foundation.md conventions when evaluating consistency
- Cite specific files and sections when describing issues

### Error Recovery
- **Fewer than 2 designs**: Report what was found, suggest completing more unit designs first.
- **Missing design files**: Report which unit is missing design docs, suggest running aidlc-design for that unit.
- **Manifest read failure**: Fall back to scanning conventional paths for unit design folders.

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check if `{WORKFLOW_DIR}/{feature}/architecture-review.md` exists:
  - Not present → restart review from Step 1 (gather documents)
  - Present but no manifest entry → present existing report, ask user if they want to re-review or proceed
  - Manifest shows `artifacts.solutions-review.status: "approved"` → review complete, recommend next step
