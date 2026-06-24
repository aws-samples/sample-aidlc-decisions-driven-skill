# Action: tasks-decisions

Generate the D4 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-tasks.md` (or `{WORKFLOW_DIR}/{feature}/units/{unit}/decisions-tasks.md` in incremental mode).

**⛔ Per-Unit Independence**: In incremental mode, ALWAYS generate a fresh D4 for each unit. Do NOT reuse another unit's D4 answers. Each unit may have different task breakdown strategies, testing approaches, or priority orderings. Read the current unit's `decisions.tasks` from manifest: if null/empty, generate a new D4. Do NOT infer from other units or from conversation history.

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- Each gate starts fresh (previous "use recommendations" does NOT carry forward)
- Include context summary from design documents (component count, entity count, endpoint count, integration count)

**Generate questions covering**:
- Task breakdown strategy
- Implementation approach (TDD vs test-after)
- Component priority (which components to build first)
- Integration strategy (how to handle external dependencies during dev)
- Testing strategy (which test types to include)
- Task granularity (how big each task should be)
- Parallel work (sequential vs parallel execution)
- Estimates (sizing format)

For each question: offer 3-4 options with brief rationale, mark one as **(Recommended)**, include "Other". Leave `**Answer**:` blank.

Present:

```
📍 Tasks: Decision Gate D4

- **Decisions**: [X] questions covering strategy, approach, priorities, testing

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-tasks.md`, fill answers, say "done"
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

# Action: validate-d4

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from design documents and previous decisions (D3 tech choices)
3. Check rules below, collect conflicts, adjust severity
4. If conflicts found → present grouped by severity, ask for resolution
5. If clean → write decision summary to manifest `decisions.tasks` → proceed to generation

**D4 Validation Rules**:

| Rule | Severity | Detection | Options |
|---|---|---|---|
| TDD Without Team Experience | 🟢 Low | Testing="TDD", team new to TDD | 1. Test-after 2. TDD for critical only 3. Keep TDD |
| No Testing Strategy | 🔴 High | Testing="None", production planned | 1. Add unit tests 2. Add integration tests 3. Keep (prototype) |
| Testing Framework Without Test Tasks | 🔴 High | Testing framework in D3, no corresponding test tasks generated | 1. Add test tasks 2. Defer to separate QA phase 3. Keep |
| Parallel Dev Without Coordination | 🟡 Medium | Breakdown="Parallel", no sync points | 1. Define sync milestones 2. Assign contracts upfront 3. Sequential |
| Outside-In Without E2E | 🟡 Medium | Testing="Outside-in", no E2E framework | 1. Select E2E framework 2. Integration as outer 3. Keep |
| E2E Framework Without E2E Tasks | 🟡 Medium | E2E framework in D3, no E2E setup + scenario tasks | 1. Add E2E setup + scenario tasks 2. Defer to QA phase 3. Remove framework |
| Load Testing Without Load Tasks | 🟡 Medium | Load testing tool in D3, no load test tasks | 1. Add load test tasks 2. Defer to performance phase 3. Remove tool |
| Task Count vs Timeline | 🔴 High | Tasks≥30, timeline<2wk, team≤3 | 1. Reduce scope 2. Extend timeline 3. Increase parallelism 4. Keep |
| Cloud Deploy Without Infra Tasks | 🔴 High | Cloud+IaC in D3, no infra tasks | 1. Add infra tasks 2. Pre-existing 3. Defer |
| DB Without Migration Tasks | 🟡 Medium | DB+ORM in D3, no migration tasks | 1. Add migration tasks 2. Sub-task of data layer 3. Pre-existing |
| CI/CD Without Pipeline Tasks | 🟡 Medium | CI/CD tool in D3, no pipeline tasks | 1. Add CI/CD tasks 2. Sub-task of setup 3. Defer |

After resolution, append validation notes and proceed.
