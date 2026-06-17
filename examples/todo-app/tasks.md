# Implementation Tasks

## Summary
- **Total Tasks**: 8 across 3 phases in 3 execution waves
- **Strategy**: Layer-by-Layer
- **Testing**: Test-after
- **Derived From**: 5 stories, 3 components, 5 endpoints

## Overview
Tasks organized by layer-by-layer strategy — infrastructure first, then data layer, then API, then polish.

**Checkbox Legend**:
- `[ ]` — Not started
- `[x]` — Completed
- `[!]` — Failed (autonomous mode only — task failed after retries, see notes)

**Derived From**:
- Requirements: 5 user stories from `requirements.md`
- Design: 3 components, 1 entity, 5 endpoints from `design.md`

**Strategy**: Layer-by-Layer
**Rationale**: Simple CRUD app with a single entity — building bottom-up ensures each layer has its foundation before the next is added.

---

- [ ] 1. Project Setup
  - [ ] 1.1 Initialize project and install dependencies
    - **Deps**: None | **Ref**: `design.md` — Implementation
    - Initialize npm project with TypeScript configuration
    - Install dependencies: express, @prisma/client, zod, dotenv
    - Install dev dependencies: typescript, ts-node, jest, supertest, @types/express, prisma
    - Create `tsconfig.json`, `jest.config.ts`, `.env.example`, `docker-compose.yml`
  - [ ] 1.2 Set up Prisma schema and database
    - **Deps**: 1.1 | **Ref**: `design.md` — Data Model
    - Create `prisma/schema.prisma` with Todo model, TodoStatus enum, and indexes
    - Create `src/lib/prisma.ts` Prisma client singleton
    - Generate initial migration

- [ ] 2. Core Features
  - [ ] 2.1 Implement Todo repository
    - **Deps**: 1.2 | **Ref**: `design.md` — Components (TodoRepository)
    - Create `src/repositories/todo.repository.ts`
    - Implement `create()`, `findMany()`, `findById()`, `update()`, `delete()` methods
    - Support optional status filter in `findMany()`
    - Write unit tests in `tests/unit/todo.repository.test.ts`
  - [ ] 2.2 Implement Todo service
    - **Deps**: 2.1 | **Ref**: `design.md` — Components (TodoService)
    - Create `src/services/todo.service.ts`
    - Implement business logic: validate status values, handle not-found cases
    - Write unit tests in `tests/unit/todo.service.test.ts` with mocked repository
  - [ ] 2.3 Implement validation schemas and error handling
    - **Deps**: 1.1 | **Ref**: `design.md` — API Specification
    - Create `src/schemas/todo.schema.ts` with Zod schemas for create, update, and query params
    - Create `src/middleware/validate.ts` validation middleware
    - Create `src/middleware/error-handler.ts` global error handler
    - Create `src/types/todo.types.ts` shared TypeScript types
  - [ ] 2.4 Implement Todo controller and routes
    - **Deps**: 2.2, 2.3 | **Ref**: `design.md` — API Specification
    - Create `src/controllers/todo.controller.ts` with handlers for all 5 endpoints
    - Create `src/routes/todo.routes.ts` with Express router
    - Create `src/app.ts` Express app setup with middleware and routes

- [ ] 3. Polish
  - [ ] 3.1 Integration tests
    - **Deps**: 2.4 | **Ref**: `requirements.md` — all acceptance criteria
    - Create `tests/integration/todo.test.ts`
    - Test all 5 endpoints including success and error cases
    - Test status filtering (US-005)
    - Test validation errors (missing title, invalid status)
  - [ ] 3.2 Documentation and final setup
    - **Deps**: 3.1 | **Ref**: `design.md` — Implementation
    - Create `README.md` with setup instructions and API documentation
    - Verify `docker-compose.yml` and `.env.example` are complete
    - Run full test suite and confirm all tests pass

---

## Task Summary

| Task | Title | Dependencies | Status |
|------|-------|--------------|--------|
| 1.1 | Initialize project and install dependencies | None | [ ] |
| 1.2 | Set up Prisma schema and database | 1.1 | [ ] |
| 2.1 | Implement Todo repository | 1.2 | [ ] |
| 2.2 | Implement Todo service | 2.1 | [ ] |
| 2.3 | Implement validation schemas and error handling | 1.1 | [ ] |
| 2.4 | Implement Todo controller and routes | 2.2, 2.3 | [ ] |
| 3.1 | Integration tests | 2.4 | [ ] |
| 3.2 | Documentation and final setup | 3.1 | [ ] |

---

## Requirements Coverage

| Requirement | Implemented By | Status |
|-------------|----------------|--------|
| US-001 Create Todo | 1.2, 2.1, 2.2, 2.3, 2.4, 3.1 | [ ] |
| US-002 List Todos | 2.1, 2.2, 2.4, 3.1 | [ ] |
| US-003 Update Todo | 2.1, 2.2, 2.3, 2.4, 3.1 | [ ] |
| US-004 Delete Todo | 2.1, 2.2, 2.4, 3.1 | [ ] |
| US-005 Filter by Status | 2.1, 2.2, 2.3, 2.4, 3.1 | [ ] |

---

## Design Coverage

**Components**: 3 components → TodoRepository (2.1), TodoService (2.2), TodoController (2.4)
**Entities**: 1 entity → Todo (1.2, 2.1)
**Endpoints**: 5 endpoints → All in 2.4, tested in 3.1
**Integrations**: 0 integrations

---

## Definition of Done

- [ ] Code written and follows standards
- [ ] Tests written and passing
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Acceptance criteria met

---

## Execution Waves

Phases grouped by dependency resolution. In parallel/autonomous mode, each phase in a wave is dispatched to its own sub-agent.

| Wave | Phases | Dependencies Resolved |
|------|--------|-----------------------|
| 1 | 1. Project Setup | None (scaffold) |
| 2 | 2. Core Features | Wave 1 (project initialized, schema ready) |
| 3 | 3. Polish | Wave 2 (all features implemented) |

### File Ownership Per Wave

**Wave 2**:
- Task 2.1: `src/repositories/`
- Task 2.2: `src/services/`
- Task 2.3: `src/schemas/`, `src/middleware/`, `src/types/`
- Task 2.4: `src/controllers/`, `src/routes/`, `src/app.ts`

**Wave 3**:
- Task 3.1: `tests/integration/`
- Task 3.2: `README.md`

---

## Notes

**Technical Debt**: None — greenfield project with clean architecture.

**Future Enhancements**: Authentication, pagination, due dates, priority levels, todo categories/tags.
