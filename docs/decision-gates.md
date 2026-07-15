# Decision Gates

Each phase has a decision gate that generates targeted questions, validates answers for conflicts, and ensures alignment before proceeding.

## Gates Overview

| Gate | Phase | Covers |
|---|---|---|
| D1 | Requirements | Feature scope, user types, core functionality, data entities, integrations, business rules, constraints |
| D2 | Decomposition | Architecture pattern, decomposition strategy, unit proposals, dependencies, development sequence |
| D3 | Design | Technology stack, frameworks, data layer, testing strategy, observability & operations, infrastructure, code organization |
| D4 | Tasks | Breakdown strategy, implementation approach (TDD/test-after), component priority, integration strategy, task granularity |
| D5 | Deploy | CI/CD platform, deployment target, deployment strategy, environments, promotion, secrets management, IaC, rollback, database migrations, post-deploy verification |

## How Decision Gates Work

1. The skill generates a decisions file with questions tailored to your project context
2. Each question offers 3-5 options with one marked as recommended
3. You fill in answers and say "done" (or say "use recommendations" to auto-fill). If any answers are left blank, the skill lists the unanswered questions and waits — it never proceeds with blanks or fills them for you
4. The skill populates the machine-readable Decisions Summary section from your answers — on both paths. Validation and all downstream phases read only that section
5. The skill validates for conflicts — e.g., "Enterprise scope with solo developer" or "Microservices with shared database"
6. Conflicts are classified by severity (🔴 Critical, 🟡 Major, 🟢 Minor) with resolution options
7. After resolution, the skill proceeds to generation

## Decision File Format

All decision files follow the same structure:

```markdown
# [Phase] Decisions

## Context Summary
[Auto-populated from previous phases]

---

## Decision Questions

### D[N]-1: [Question Title]
**Question**: [Clear, specific question]
- 1) [Option 1 with brief explanation]
- 2) [Option 2 with brief explanation] **(Recommended)**
- 3) [Option 3 with brief explanation]
- 4) Other (please specify): _______

**Answer**: 

---

## Decisions Summary
- D[N]-1 [Short Label]: [User's answer]
- D[N]-2 [Short Label]: [User's answer]
```

## Conflict Validation

Each gate has specific validation rules. Examples:

| Conflict | Gate | Severity | Detection |
|---|---|---|---|
| Microservices for Small Team | D2 | 🔴 High | arch=Microservices AND teamSize=solo/small |
| Circular Dependencies | D2 | 🔴 High | Unit A→B→A |
| Prisma + MongoDB Limited Support | D3 | 🟡 Medium | ORM=Prisma AND DB=MongoDB |
| Serverless with Long-Running Tasks | D3 | 🔴 High | Compute=Lambda AND requirements mention batch |
| Platform Mismatch | D5 | 🔴 Critical | CI platform doesn't support deployment target |

User can always say "skip validation and proceed" — logged in audit with a warning.
