# Action: unit-decisions

Generate the D2 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-units.md`.

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- Each gate starts fresh
- Include context summary from requirements.md and context.md
- Generate questions covering:
  - Decomposition need
  - Architecture pattern: Modular Monolith / Microservices / Distributed / Single Unit
  - Decomposition strategy: Domain-Driven / Layer-Based / User Journey-Based / Hybrid
  - Unit proposals with story assignments
  - Dependencies: How units interact (data, API, events)
  - Development sequence

Present:

```
📍 Decomposition: Decision Gate D2

- **Decisions**: [X] questions covering decomposition, architecture, strategy, units

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-units.md`, fill answers, say "done"
🤖 Or say "use recommendations" to auto-fill with recommended options

---
🔲 **Your turn**:
- ✏️ Fill answers in the file and say "done"
- 🤖 "use recommendations" — auto-fill recommended options for THIS gate
```

**STOP — do NOT continue. Do NOT fill answers yourself, even if choices seem obvious. Wait for user to say "done" or "use recommendations".**

When user says "done" or "use recommendations":
- If "use recommendations": fill all answers with the recommended option, update the Decisions Summary section
- Proceed to validation

---

# Action: validate-d2

**D2 Validation Rules**:

| Rule | Severity | Detection | Options |
|---|---|---|---|
| Over-Decomposition for Small Project | 🟡 Medium | stories≤10 AND units≥4 AND teamSize∈{solo,small} | 1. Reduce to 2-3 units 2. Skip decomposition 3. Keep |
| Microservices for Small Team | 🔴 High | arch=Microservices AND teamSize∈{solo,small} AND stories≤15 | 1. Modular Monolith 2. Keep Microservices 3. Hybrid |
| Circular Dependencies | 🔴 High | Unit A→B→A | 1. Shared library 2. Merge units 3. Refactor 4. Event-driven |
| Unit Too Small | 🟡 Medium | Unit has <2 stories | 1. Merge into related unit 2. Keep 3. Add stories |
| Unit Too Large | 🟡 Medium | Unit has >15 stories | 1. Split into sub-units 2. Defer low-priority 3. Keep |
| Bottleneck Unit | 🟡 Medium | Unit has >3 dependents | 1. Extract shared interface 2. Duplicate minimal logic 3. Keep |
| Missing Shared Kernel | 🟡 Medium | 3+ units share entities, no shared package | 1. Add shared types unit 2. One unit owns, others consume 3. Keep separate |
| Unbalanced Distribution | 🟢 Low | Largest 3x+ more than smallest | 1. Rebalance 2. Keep (natural boundaries) |

After resolution, write decision summary to manifest `decisions.decomposition`.
