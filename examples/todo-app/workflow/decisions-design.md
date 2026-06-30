# Design Decisions

## Context Summary
- **Project**: Greenfield Todo App
- **Stack**: TypeScript / Express / PostgreSQL
- **Stories**: 5 user stories, 1 entity, 0 integrations
- **Complexity**: Low
- **Team Size**: Solo

---

## Decision Questions

### D3-1: Backend Framework
**Question**: Which backend framework for handling HTTP requests?
- 1) Express — lightweight, mature, huge ecosystem **(Recommended)**
- 2) NestJS — opinionated, built-in DI, decorators
- 3) Fastify — high performance, schema-based validation
- 4) Hono — ultra-lightweight, edge-ready
- 5) Other (please specify): _______

**Answer**: 1

---

### D3-2: ORM / Data Access
**Question**: How will you access PostgreSQL?
- 1) Prisma — type-safe, migrations, great DX **(Recommended)**
- 2) Drizzle — lightweight, SQL-like syntax, type-safe
- 3) TypeORM — decorator-based, active record + data mapper
- 4) Raw SQL with pg driver
- 5) Other (please specify): _______

**Answer**: 1

---

### D3-3: Input Validation
**Question**: How will request input be validated at runtime?
- 1) Zod — runtime validation with TypeScript type inference **(Recommended)**
- 2) class-validator — decorator-based, pairs with class-transformer
- 3) Joi — mature, expressive schema language
- 4) AJV — JSON Schema based, very fast
- 5) Other (please specify): _______

**Answer**: 1

---

### D3-4: API Design Pattern
**Question**: What API style for client communication?
- 1) REST with standard HTTP methods and status codes **(Recommended)**
- 2) GraphQL — flexible queries, single endpoint
- 3) tRPC — end-to-end type safety, no schema generation
- 4) Other (please specify): _______

**Answer**: 1

---

### D3-5: Error Handling Strategy
**Question**: How are errors formatted and communicated to clients?
- 1) Consistent JSON format with centralized error middleware **(Recommended)**
- 2) HTTP status codes only (no body for errors)
- 3) RFC 7807 Problem Details format
- 4) Other (please specify): _______

**Answer**: 1

---

### D3-6: Testing Framework
**Question**: Which testing framework and tools?
- 1) Jest + supertest — standard for Express, good TS support **(Recommended)**
- 2) Vitest + supertest — faster, ESM-native
- 3) Mocha + Chai + supertest — flexible, modular
- 4) Other (please specify): _______

**Answer**: 1

---

### D3-7: Code Organization
**Question**: How is the codebase structured?
- 1) Layered — controller → service → repository **(Recommended)**
- 2) Feature-based — group by feature (todo/controller, todo/service)
- 3) Flat — all files in src/ with naming conventions
- 4) Other (please specify): _______

**Answer**: 1

---

### D3-8: Database Schema Management
**Question**: How are database schema changes managed?
- 1) Prisma Migrate — integrated with ORM, auto-generated **(Recommended)**
- 2) Manual SQL migration files
- 3) Knex migrations — programmatic, flexible
- 4) Other (please specify): _______

**Answer**: 1

---

### D3-9: Correctness & Property-Based Testing
**Question**: Should this project use property-based testing for critical logic?
- 1) No — standard example-based tests are sufficient **(Recommended)**
- 2) Yes — use fast-check for invariant testing
- 3) Partial — property-based for core logic only
- 4) Other (please specify): _______

**Answer**: 1

---

## Decisions Summary
- D3-1 Backend Framework: Express
- D3-2 ORM: Prisma
- D3-3 Validation: Zod
- D3-4 API Style: REST
- D3-5 Error Handling: Centralized middleware, JSON format
- D3-6 Testing: Jest + supertest
- D3-7 Code Organization: Layered (controller → service → repository)
- D3-8 Schema Management: Prisma Migrate
- D3-9 Property Testing: No
