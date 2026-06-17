# Action: requirements-decisions

Generate the D1 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-requirements.md`.

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward
- Include context summary from context input
- Generate questions covering: feature scope, user types, core functionality, data entities, integrations, business rules, constraints, priorities
- **MANDATORY**: Include explicit personas question
- **MANDATORY**: Include team size question — "How many developers will work on this project?" with options: 1) Solo (1 developer), 2) Small team (2–3), 3) Medium team (4–8), 4) Large team (9+). This is used by downstream validation rules in D2, D3, and DF gates.

Present:

```
📍 Requirements: Decision Gate D1

- **Decisions**: [X] questions covering scope, users, features, integrations

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-requirements.md`, fill answers, say "done"
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

# Action: validate-d1

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from context.md (scope, timeline)
3. Read team size from D1 answers (team-size question)
4. Check each rule below against user answers
5. Collect conflicts, adjust severity by context
6. If conflicts found → present grouped by severity (🔴 High → 🟡 Medium → 🟢 Low), ask for resolution
7. If clean or all resolved → write decision summary to manifest `decisions.requirements` → proceed to generation

**D1 Validation Rules**:

| Rule | Severity | Detection | Questions | Options |
|---|---|---|---|---|
| Scope vs Timeline Mismatch | 🟡 Medium | Scope="Full product"/"Enterprise" AND timeline<3mo AND stories>15 | Is timeline realistic? Can we prioritize for phased delivery? | 1. Reduce to MVP 2. Extend timeline 3. Increase team 4. Keep (justify) |
| Complex Features Without Personas | 🟢 Low | User types≥3 AND personas=No | Do different user types have significantly different needs? | 1. Generate personas 2. Skip personas |
| Many Integrations Without Priority | 🟡 Medium | Integrations≥3, no priority indicated | Which integrations are required for MVP? | 1. Prioritize integrations 2. Reduce to core only 3. Keep all |
| Broad Scope Without Boundaries | 🟡 Medium | Scope covers 3+ areas, no exclusions | What is explicitly out of scope? | 1. Define out-of-scope items 2. Split into phases 3. Keep broad scope |
| Enterprise Scope Solo Developer | 🔴 High | Scope="Full product"/"Enterprise" AND team=1 | Can scope be reduced to MVP? | 1. Reduce to MVP 2. Plan phased delivery 3. Bring help 4. Keep (justify) |
| Heavy Integration Load | 🔴 High | Integrations≥5, no phased delivery | Which integrations are critical for launch? | 1. Phase integrations 2. Use mock/stubs 3. Keep all |
| Compliance Without Security Stories | 🔴 High | GDPR/HIPAA/SOC2/PCI mentioned, no privacy stories | Which compliance requirements apply? | 1. Add compliance stories 2. Defer to separate phase 3. Non-production |
| Performance Without NFR Flag | 🟡 Medium | "scalable"/"real-time"/"high traffic" mentioned, NFR=No | Are there specific performance targets? | 1. Enable NFR analysis 2. Add perf criteria to stories 3. Skip NFR |
| Real-Time Without Technical Stories | 🟡 Medium | "real-time"/"live updates" mentioned, no push stories | Which features need real-time? | 1. Add real-time stories 2. Use polling for MVP 3. Clarify requirements |
| Multi-Platform Without Capacity | 🟡 Medium | Platforms≥3, team≤3 | Which platform is primary? | 1. Primary platform first 2. Cross-platform framework 3. Keep all |

After resolution, append validation notes to the decisions file and proceed.
User can say "skip validation and proceed" → log in audit, add warning, proceed.
