# D3 Validation Rules — Consolidated

Load relevant sections based on D3 answer categories.

## Foundation Consistency (Incremental Mode)

> Load when `state.mode` = `incremental` AND `foundation` in `state.sharedPhases`. Read foundation decisions from manifest `decisions.foundation`.

| Rule | Detection | Severity | Questions | Options |
|---|---|---|---|---|
| Auth Mismatch | Foundation auth ≠ D3 auth (e.g., Foundation="JWT", D3="Session") | 🔴 High | D3 auth choice conflicts with foundation convention. Which should this unit use? | 1. Use foundation convention ({foundation auth}) 2. Override for this unit (justify deviation) 3. Update foundation to match D3 |
| API Style Mismatch | Foundation comms ≠ D3 api-style (e.g., Foundation="REST", D3="GraphQL") | 🔴 High | D3 API style conflicts with foundation inter-unit communication pattern. | 1. Use foundation convention ({foundation comms}) 2. Override for this unit (justify — e.g., public API vs internal) 3. Update foundation |
| Database Mismatch | Foundation db ≠ D3 database (e.g., Foundation="PostgreSQL shared schemas", D3="MongoDB") | 🟡 Medium | D3 database choice differs from foundation strategy. Intentional? | 1. Use foundation database strategy 2. Override for this unit (polyglot persistence — justify) 3. Update foundation |
| Error Format Mismatch | Foundation error-format ≠ D3 error-format | 🟡 Medium | D3 error format differs from foundation convention. | 1. Use foundation convention 2. Override for this unit (justify) 3. Update foundation |

**Context-Based Severity Adjustments**:
- If the unit is an infrastructure unit → mismatches are always 🔴 High (infra sets the standard)
- If the unit has no inter-unit dependencies → database/API mismatches can be downgraded to 🟡 Medium

---

## Technology Compatibility

> Load when D3 includes technology stack choices (frameworks, ORMs, databases, IaC, testing tools).

| Rule | Detection | Severity | Questions | Options |
|---|---|---|---|---|
| Prisma + MongoDB Limited Support | ORM="Prisma" AND DB="MongoDB" | 🟡 Medium | Prisma's MongoDB support is limited (no migrations). Need full ORM features? | 1. Switch to Mongoose 2. Keep Prisma+MongoDB (accept limitations) 3. Switch to PostgreSQL |
| GraphQL Without Proper Client | API="GraphQL" AND Client="Axios"/"Fetch" | 🟡 Medium | How will frontend consume GraphQL? Need subscriptions/caching? | 1. Apollo Client/urql 2. Fetch with manual queries 3. Switch to REST |
| AWS CDK with Non-AWS Cloud | IaC="AWS CDK" AND Cloud="Azure"/"GCP" | 🔴 High | AWS CDK only works with AWS. Intentional? | 1. Switch to AWS 2. Switch to Terraform/Pulumi 3. Use cloud-specific IaC |
| Serverless with Long-Running Tasks | Compute="Lambda"/"Serverless" AND requirements mention batch/long-running | 🔴 High | Serverless has execution time limits. How will long-running tasks be handled? | 1. ECS/Fargate for long tasks 2. Step Functions 3. Async with queues 4. Hybrid Lambda+ECS |
| NestJS Requires TypeScript | Backend="NestJS" AND Language="JavaScript" | 🔴 High | NestJS requires TypeScript. Switch language or framework? | 1. Switch to TypeScript 2. Use Express instead 3. Keep NestJS with TS |
| Drizzle ORM with MongoDB | ORM="Drizzle" AND DB="MongoDB" | 🔴 High | Drizzle does not support MongoDB. It's SQL-only. | 1. Switch to Mongoose/Prisma 2. Switch to PostgreSQL/MySQL with Drizzle 3. Use MongoDB native driver |
| API Gateway 30s Timeout with Heavy Processing | Compute="Lambda" AND API="API Gateway" AND heavy processing | 🔴 High | API Gateway has a 30-second hard timeout. | 1. Async with SQS/Step Functions 2. Use ALB instead 3. Move to ECS/Fargate 4. Optimize to fit 30s |

## Architecture & Performance

> Load when D3 includes architecture patterns or performance/availability targets.

| Rule | Detection | Severity | Questions | Options |
|---|---|---|---|---|
| Event Sourcing for Simple CRUD | Event Sourcing="Yes" AND mostly CRUD AND stories ≤ 10 | 🟡 Medium | Is Event Sourcing justified for a simple CRUD app? | 1. Traditional state storage 2. Audit logging instead 3. Keep Event Sourcing |
| CQRS Without Justification | CQRS="Yes" AND no different read/write patterns | 🟡 Medium | Are read/write patterns different enough to justify CQRS? | 1. Unified model 2. Keep CQRS 3. Start simple, add later |
| Microservices with Shared Database | Architecture="Microservices" AND DB="shared" | 🔴 High | Shared database defeats microservices data isolation. | 1. Database per service 2. Schema separation 3. Switch to Modular Monolith |
| High Availability Without Redundancy | Availability ≥ 99.9% AND single instance | 🔴 High | How will you achieve HA without redundancy? | 1. Multi-AZ + LB 2. DB replication 3. Lower target 4. Managed services |

## Security

> Load when D3 includes security choices, PII/compliance, or frontend+backend combinations.

| Rule | Detection | Severity | Questions | Options |
|---|---|---|---|---|
| PII Data Without Encryption | PII mentioned AND encryption="None"/"In transit only" | 🔴 High | PII without encryption at rest is a compliance risk. | 1. Encryption at rest 2. Field-level encryption 3. Justify (non-production) |
| Public API Without Rate Limiting | API is public AND rate limiting="None" | 🟡 Medium | Public API without rate limiting is vulnerable to abuse. | 1. Rate limiting 2. API gateway 3. Keep none (internal only) |
| JWT Without Refresh Token Strategy | Auth="JWT" AND no refresh tokens AND expiry > 1hr | 🟡 Medium | Long-lived JWTs can't be revoked if compromised. | 1. Short-lived + refresh tokens 2. Token blacklist 3. Keep (low-risk app) |
| CORS Wildcard in Production | CORS="*" AND production | 🔴 High | CORS wildcard allows any origin. | 1. Restrict to specific origins 2. Public API only 3. Keep (truly public, no auth) |
| API Keys in Client-Side Code | Auth includes "API keys" AND frontend is SPA/mobile | 🔴 High | API keys in client code are extractable. | 1. OAuth2/JWT for client, API keys server-to-server 2. Backend proxy 3. Keep (public/read-only) |

## Workflow & Cost

> Load when D3 includes repo strategy, CI/CD, observability, or cost-sensitive infrastructure.

| Rule | Detection | Severity | Questions | Options |
|---|---|---|---|---|
| Monorepo Without Monorepo Tool | Repo="Monorepo" AND tool="None" AND multiple packages | 🟡 Medium | Monorepo without tooling gets hard to manage. | 1. Nx/Turborepo/pnpm workspaces 2. Native workspaces 3. Keep manual |
| MVP with Enterprise Observability | Scope="MVP" AND full observability | 🟢 Low | Enterprise observability for MVP adds complexity. | 1. Basic logging+metrics 2. Keep full 3. Phased approach |
| Small Team with Complex Architecture | Team ≤ 3 (manifest `context-summary.teamSize`∈{solo,small}) AND Microservices AND multiple DBs/queues | 🟡 Medium | Complex architecture with small team adds overhead. | 1. Simplify 2. Managed services 3. Keep complex |

**Context-Based Severity Adjustments**:
- **Team Size** (from manifest `context-summary.teamSize`): Solo/Small → complexity UP; Large → DOWN
- **Scope** (from manifest `context-summary.impact` + `context-summary.complexity`): MVP/Low complexity → over-engineering UP; Enterprise/High complexity → under-engineering UP
- **Timeline** (from D1 decisions or context.md if available): Urgent (<3mo) → complexity UP; Long-term (>6mo) → DOWN
