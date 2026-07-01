# Action: design-decisions

Generate the D3 decisions file at `{WORKFLOW_DIR}/{feature}/decisions-design.md` (or `{WORKFLOW_DIR}/{feature}/units/{unit}/decisions-design.md` in incremental mode).

**⛔ Per-Unit Independence**: In incremental mode, ALWAYS generate a fresh D3 for each unit. Do NOT reuse another unit's D3 answers — even if the technology stack is the same. Each unit may have different architectural constraints, integration patterns, or component boundaries. Read the current unit's `decisions.design` from manifest: if null/empty, generate a new D3. Do NOT infer from other units or from conversation history.

Analyze the **FULL SYSTEM** before generating questions — read requirements, units (if exists), context. If designing a non-foundation unit in incremental mode, also read the foundation unit's design (if it exists) at `{SPECS_DIR}/{feature}/units/foundation/design/` for shared conventions.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- If user said "use recommendations" on a previous gate, that does NOT carry forward — each gate starts fresh
- **Skip questions** that the foundation unit's design already answers (repo strategy, API architecture, auth approach, error format, inter-unit comms, DB strategy, shared types) — those decisions are settled. Do NOT include them in the decisions file. Only applies when a foundation unit exists and has completed its design phase.
- **No version suffixes in options**: Present tool/library names WITHOUT version numbers (e.g., "Express" not "Express 4.x", "Prisma" not "Prisma 5.x"). Version resolution happens later during design generation (Step 0.5) using live registry lookups. Hardcoding versions in D3 options causes them to go stale.

Read `{REFERENCES_DIR}/technology-questions-catalog.md` (the **index file** — it lists which sub-catalogs to load), then load ONLY the relevant sub-catalogs based on context:

| Sub-Catalog | Load When |
|---|---|
| `{REFERENCES_DIR}/tech-catalog-backend.md` | **ALWAYS** (most projects have backend) |
| `{REFERENCES_DIR}/tech-catalog-frontend.md` | System has web UI |
| `{REFERENCES_DIR}/tech-catalog-mobile.md` | System has mobile app |
| `{REFERENCES_DIR}/tech-catalog-infra.md` | Cloud-deployed |
| `{REFERENCES_DIR}/tech-catalog-distributed.md` | Architecture = microservices or distributed |
| `{REFERENCES_DIR}/tech-catalog-nfr.md` | Production deployment or performance targets |

**Stack-aware filtering**: After loading catalogs, use `context-summary.stack` from the manifest to filter options. For each question, present ONLY options compatible with the detected stack:
- If stack = TypeScript → show only JS/TS-ecosystem options (Express, NestJS, Jest, Vitest, Prisma, etc.)
- If stack = Python → show only Python-ecosystem options (FastAPI, Django, pytest, SQLAlchemy, etc.)
- If stack = Java → show only JVM options (Spring Boot, JUnit, Hibernate, etc.)
- If stack = Go → show only Go options (Gin, Echo, go test, GORM, etc.)
- If stack is unknown/greenfield → show top 3-4 options per category across ecosystems

This prevents the model from presenting irrelevant choices (e.g., "Log4j" for a TypeScript project) and reduces question verbosity by ~60%.

Select 8–15 questions total based on project complexity.

**MANDATORY**: Include the Correctness & Property-Based Testing question.

**MANDATORY (unless scope = `bugfix` or `refactor`)**: Include the Operations & Observability questions below.

---

## Operations & Observability Questions (D3-Ops)

**Include when**: scope is `new` or `feature`. **Skip when**: scope is `bugfix` or `refactor`.

These questions are ALWAYS included (not from sub-catalogs) when the scope condition is met. They determine the level of operational infrastructure generated in `design/operations.md`.

### Required Operations Questions

```markdown
### D3-[N]: Observability Strategy
**Question**: What level of observability does this service need?
- 1) Minimal — structured logging + health endpoint (sufficient for internal tools, dev projects)
- 2) Standard — logging + metrics + health + readiness **(Recommended for production services)**
- 3) Full — logging + metrics + distributed tracing + alerting + dashboards (for critical services with SLAs)
- 4) None — skip observability entirely (prototype only)
- 5) Other (please specify): _______

**Answer**: 

---

### D3-[N+1]: Error Tracking
**Question**: How should runtime errors be captured and reported?
- 1) Log-based only — errors in structured logs, query via log aggregation platform **(Recommended for simple services)**
- 2) Dedicated error tracking service — Sentry / Datadog / Rollbar **(Recommended for production with on-call)**
- 3) Cloud-native — CloudWatch Insights / GCP Error Reporting / Azure Monitor
- 4) None — no error tracking beyond basic logging
- 5) Other (please specify): _______

**Answer**: 

---

### D3-[N+2]: Health & Lifecycle Management
**Question**: What lifecycle management does the service need?
- 1) Basic health endpoint only (sufficient for simple deployments)
- 2) Health + readiness + graceful shutdown **(Recommended for containerized/orchestrated)**
- 3) Health + readiness + graceful shutdown + startup probe + drain delay (for zero-downtime deployments with warm-up)
- 4) Other (please specify): _______

**Answer**: 
```

**Stack-aware option filtering for operations questions**:
- Observability options stay the same across stacks (they're level-based, not tool-based)
- Error tracking option 3 (cloud-native): only show the sub-option matching the detected cloud provider
- Health/lifecycle option 3: only relevant when target deployment is Kubernetes or similar orchestrator

**Recommendation logic**:
- Solo dev / internal tool / prototype → recommend Minimal + Log-based + Basic
- Production service (any team size) → recommend Standard + Log-based + Health+readiness+graceful
- Critical service with SLA or on-call team → recommend Full + Dedicated + Health+readiness+graceful+drain

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

Present the decision file:

```
📍 Design: Decision Gate D3

- **Decisions**: [X] questions covering stack, data, auth, testing, infrastructure

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-design.md`, fill answers, say "done"
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

# Action: validate-d3

After D3 answers are filled, validate for conflicts.

**Validation Process**:
1. Parse all answers from the decisions file (read Decisions Summary section)
2. Load context from manifest `context-summary` (teamSize, complexity, impact) and context.md
3. Check ONLY the relevant rule sets below based on D3 answer categories
4. Collect conflicts, adjust severity by context
5. If conflicts found → present grouped by severity (🔴 High → 🟡 Medium → 🟢 Low), ask for resolution
6. If clean or all resolved → write decision summary to manifest `decisions.design` (compact key-value pairs from Decisions Summary section) → proceed to generation

**Load validation rules from `{REFERENCES_DIR}/validation-rules-d3.md`** — read only the relevant sections based on D3 answer categories:
- **Foundation Consistency** → if `state.mode` = `incremental` AND a foundation unit exists with completed design (check `units[name=foundation].completedPhases` contains `design`)
- **Technology Compatibility** → if D3 includes technology stack choices
- **Architecture & Performance** → if D3 includes architecture patterns or performance targets
- **Security** → if D3 includes security choices, PII/compliance, or frontend+backend combinations
- **Workflow & Cost** → if D3 includes repo strategy, CI/CD, observability, or cost-sensitive infrastructure
- **Operations & Observability** → if D3 includes operations questions (always, unless scope skips them)

**Operations-Specific Validation Rules** (inline — no external file needed):

| Conflict | Severity | Detection | Resolution |
|---|---|---|---|
| Full observability for solo/prototype | 🟡 Medium | observability=Full AND (teamSize=solo OR complexity=Low) | Downgrade to Standard or justify |
| No observability for production | 🟡 Medium | observability=None AND scope=`feature` AND context-summary.impact≠"prototype" | Upgrade to Minimal or justify |
| Dedicated error tracking without metrics | 🟢 Low | error-tracking=Dedicated AND observability=Minimal | Consider Standard (metrics help correlate errors) |
| Full lifecycle without container target | 🟢 Low | lifecycle=option3 AND no container/K8s in D3 infra choices | Downgrade to option 2 unless specific need |

**Context-Based Severity Adjustments**:
- **Team Size**: Small (1–3) → complexity conflicts severity UP; Large (9+) → DOWN
- **Scope**: MVP → over-engineering severity UP; Enterprise → under-engineering severity UP
- **Timeline**: Urgent (<3mo) → complexity severity UP; Long-term (>6mo) → DOWN

**Conflict presentation**:
```
⚠️ Decision Validation — Conflicts Detected

## 🔴 Conflict 1: [Name] (High)
**Issue**: [Description]
**Your choices**: [Decision A]: [answer], [Decision B]: [answer]
**Options**: 1. [option] 2. [option] 3. Keep current (requires justification)
**Question**: How would you like to resolve this?
```

After resolution, append validation notes to the decisions file and proceed.

User can say "skip validation and proceed" → log in audit, add warning, proceed.
