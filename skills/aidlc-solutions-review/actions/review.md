# Action: review-designs

## Step 1: Gather Documents

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
- `foundation unit design` — for shared conventions baseline (if foundation unit exists and has been designed)

Extract from each unit: key decisions, technologies, API patterns, data models, error handling, auth approach, integration points.

## Step 2: Identify Conflicts

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

**Foundation Compliance** (if foundation unit design exists):
- Deviations from agreed conventions (naming, error format, auth approach)
- Missing shared patterns (unit doesn't use the agreed error handling)
- Inconsistent with repo structure conventions

## Step 3: Analyze Impact

For each identified conflict:
- Which units are affected
- Severity classification:
  - 🔴 **Critical**: Blocks implementation or causes runtime failures. Must resolve before proceeding.
  - 🟡 **Major**: Causes inconsistency or maintenance burden. Should resolve before implementation.
  - 🟢 **Minor**: Cosmetic or stylistic inconsistency. Can resolve during implementation.

Finding IDs use the `SR-` namespace prefix (e.g., `SR-CR-1`, `SR-MJ-1`, `SR-MN-1`) to distinguish from code-review findings.
- Downstream effects (what breaks if not resolved)
- Whether it affects the integration contracts between units

## Step 4: Recommend Solutions

For each conflict, provide:
- Clear description of the issue
- Which units need to change
- Recommended resolution (specific: "Unit A should change endpoint X to match Unit B's contract")
- Alternatives if applicable
- Effort estimate (trivial / small / medium / large)

## Step 5: Generate Report

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

## Step 6: Present Results

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

## Audit Entry

```
### [{ISO timestamp}] Solutions Review: Complete

**Phase**: solutions-review
**Action**: review-complete
**Artifacts**: architecture-review.md
**Outcome**: {X} critical, {Y} major, {Z} minor findings. Go/No-Go: {recommendation}.
```
