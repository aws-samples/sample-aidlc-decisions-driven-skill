# Action: foundation-decisions

Generate the DF decisions file at `{WORKFLOW_DIR}/{feature}/decisions-foundation.md`.

Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for the output structure.

**Rules**:
- Always generate with blank `Answer:` fields — never pre-fill
- Each gate starts fresh
- Include context from units.md, requirements.md, and context.md
- Architecture pattern from D2 (units.md Summary) informs which questions to ask

**Generate questions covering**:
- Primary language & runtime (for brownfield, pre-fill from context.md)
- Package manager & monorepo tooling (if monorepo)
- Team structure: Solo / Small team (2-3) / Multiple teams (4+)
- Repository strategy: Monorepo / Multi-repo / Hybrid
- Shared foundations level: Everything shared / Interfaces only / Minimal
- API architecture: Gateway / BFF / Direct / Hybrid (microservices/distributed only)
- Frontend hosting (if frontend units exist)
- Shared UI components (if multiple frontend units)
- Authentication: JWT / Session / OAuth2 / API keys
- Error handling format: RFC 7807 / Custom envelope / Framework default
- Inter-unit communication: REST / Events / gRPC / Mixed
- Database strategy: Shared DB separate schemas / DB per unit / Mixed
- Shared types strategy: Shared package / Code generation / Manual sync
- Infrastructure units needed: Gateway / BFF / Auth service / Event bus / None
- Infrastructure unit strategy: Combined / Separate
- CI/CD pipeline, Branch strategy, Deployment strategy

For solo developers: still ask technical questions but mark team/process questions as skippable.

Present:

```
📍 Foundation: Decision Gate DF

- **Decisions**: [X] questions covering team, repo, API, auth, comms, DB, infrastructure

📝 Open `{WORKFLOW_DIR}/{feature}/decisions-foundation.md`, fill answers, say "done"
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

# Action: validate-df

**DF Validation Rules**:

| Rule | Severity | Detection | Options |
|---|---|---|---|
| Microservices with Shared Schema | 🔴 High | arch=Microservices AND DB=shared schema | 1. Separate schemas 2. DB per unit 3. Modular Monolith 4. Keep |
| Event-Driven Without Broker | 🔴 High | comms=Events AND no Event Bus unit | 1. Add Event Bus unit 2. Cloud-managed broker 3. Switch to REST |
| API Gateway Without Gateway Unit | 🟡 Medium | API=Gateway AND no Gateway unit | 1. Add Gateway unit 2. Cloud-managed gateway 3. Switch to Direct |
| BFF Without Frontend Diversity | 🟡 Medium | API=BFF AND single frontend type | 1. Switch to Gateway 2. Keep BFF 3. Switch to Direct |
| Multi-Repo with Heavy Shared Types | 🟡 Medium | repo=Multi-repo AND types=Shared package | 1. Switch to monorepo 2. Code generation 3. Keep |
| Solo Dev with Complex Infrastructure | 🟡 Medium | teamSize=solo AND infra units≥2 | 1. Reduce infra 2. Managed services 3. Keep |
| Manual Sync Multiple Teams | 🔴 High | teamSize=large AND types=Manual sync | 1. Shared package 2. Code generation 3. Keep |
| Session Auth with Microservices | 🔴 High | auth=Session AND arch=Microservices | 1. JWT 2. OAuth2 3. Shared session store 4. Keep |
| Event-Driven Without Idempotency | 🔴 High | comms=Events AND no idempotency | 1. Add idempotency keys 2. Exactly-once delivery 3. Natural idempotency 4. Accept at-least-once |
| Shared DB No Schema Isolation | 🔴 High | arch=Microservices AND DB=Shared AND no isolation | 1. Separate schemas 2. DB per unit 3. ORM access control 4. Modular Monolith |
| Multiple Frontends Without Shared UI | 🟡 Medium | frontend units≥2 AND shared UI=None | 1. Shared component library 2. Common CSS framework 3. Keep separate 4. Defer |

After resolution, write decision summary to manifest `decisions.foundation`.
