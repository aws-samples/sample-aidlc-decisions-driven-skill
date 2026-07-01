# Design: Todo App

## Summary
- **Architecture**: Layered — simple CRUD app, clear separation of concerns without over-engineering
- **Stack**: TypeScript / Express / PostgreSQL / Prisma
- **Components**: 3 — TodoController, TodoService, TodoRepository
- **Entities**: 1 — Todo
- **Endpoints**: 5 — CRUD + filter

## Architecture

**Pattern**: Layered (Controller → Service → Repository)

```
┌─────────────────────────────────────────┐
│              HTTP Client                │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│          Express Router                 │
│         POST/GET/PATCH/DELETE            │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│          TodoController                 │
│     Validation · Request parsing        │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           TodoService                   │
│        Business logic                   │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         TodoRepository                  │
│        Prisma data access               │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│           PostgreSQL                    │
└─────────────────────────────────────────┘
```

---

## Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Runtime | Node.js 20 LTS | Stable, TypeScript-native |
| Framework | Express 4.x | Lightweight, well-documented |
| Language | TypeScript 5.x | Type safety, better DX |
| ORM | Prisma 5.x | Type-safe queries, migrations |
| Database | PostgreSQL 16 | Reliable, feature-rich |
| Validation | Zod 3.x | Runtime schema validation |
| Testing | Jest + supertest | Standard for Express APIs |

---

## Components

### TodoController
- **Purpose**: Handle HTTP requests and responses for todo operations
- **Technology**: Express request handlers
- **Responsibilities**: Parse request params/body, validate input with Zod, delegate to service, format HTTP responses
- **Exposes**: Route handlers mounted at `/api/todos`
- **Consumes**: TodoService

### TodoService
- **Purpose**: Encapsulate business logic for todo operations
- **Technology**: Plain TypeScript classes
- **Responsibilities**: Enforce business rules (valid status transitions, field constraints), orchestrate repository calls
- **Exposes**: `create()`, `findAll()`, `findById()`, `update()`, `delete()`
- **Consumes**: TodoRepository

### TodoRepository
- **Purpose**: Data access layer for the Todo entity
- **Technology**: Prisma Client
- **Responsibilities**: CRUD operations, query filtering, ordering
- **Exposes**: `create()`, `findMany()`, `findById()`, `update()`, `delete()`
- **Consumes**: Prisma Client (PostgreSQL)

---

## Data Model

### Todo
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, auto-generated | Unique identifier |
| title | String | NOT NULL, 1–200 chars | Todo title |
| description | String | Nullable | Optional details |
| status | Enum | NOT NULL, default "pending" | "pending" or "completed" |
| createdAt | DateTime | NOT NULL, auto-set | Creation timestamp |
| updatedAt | DateTime | NOT NULL, auto-updated | Last modification timestamp |

**Relationships**: None (single entity)
**Indexes**: `status` (for filter queries), `createdAt` (for default ordering)

### Prisma Schema
```prisma
enum TodoStatus {
  pending
  completed
}

model Todo {
  id          String     @id @default(uuid())
  title       String     @db.VarChar(200)
  description String?
  status      TodoStatus @default(pending)
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt

  @@index([status])
  @@index([createdAt])
}
```

---

## API Specification

**Base Path**: `/api/todos`
**Content Type**: `application/json`
**Error Format**: `{ "error": { "code": "string", "message": "string" } }`

### POST /api/todos
- **Description**: Create a new todo
- **Auth**: Public
- **Request**: `{ "title": "string (required)", "description": "string (optional)" }`
- **Response 201**: `{ "id": "uuid", "title": "string", "description": "string|null", "status": "pending", "createdAt": "ISO8601", "updatedAt": "ISO8601" }`
- **Errors**: 400 (missing/invalid title)

### GET /api/todos
- **Description**: List all todos, optionally filtered by status
- **Auth**: Public
- **Query Params**: `status` (optional, "pending" | "completed")
- **Response 200**: `[{ "id": "uuid", "title": "string", "description": "string|null", "status": "string", "createdAt": "ISO8601", "updatedAt": "ISO8601" }]`
- **Errors**: 400 (invalid status value)

### GET /api/todos/:id
- **Description**: Get a single todo by ID
- **Auth**: Public
- **Response 200**: `{ "id": "uuid", "title": "string", "description": "string|null", "status": "string", "createdAt": "ISO8601", "updatedAt": "ISO8601" }`
- **Errors**: 404 (todo not found)

### PATCH /api/todos/:id
- **Description**: Update a todo's title, description, or status
- **Auth**: Public
- **Request**: `{ "title": "string (optional)", "description": "string (optional)", "status": "pending|completed (optional)" }`
- **Response 200**: `{ "id": "uuid", "title": "string", "description": "string|null", "status": "string", "createdAt": "ISO8601", "updatedAt": "ISO8601" }`
- **Errors**: 400 (invalid fields), 404 (todo not found)

### DELETE /api/todos/:id
- **Description**: Delete a todo
- **Auth**: Public
- **Response 204**: No content
- **Errors**: 404 (todo not found)

---

## Implementation

### Directory Structure
```
todo-app/
├── prisma/
│   └── schema.prisma
├── src/
│   ├── controllers/
│   │   └── todo.controller.ts
│   ├── services/
│   │   └── todo.service.ts
│   ├── repositories/
│   │   └── todo.repository.ts
│   ├── routes/
│   │   └── todo.routes.ts
│   ├── schemas/
│   │   └── todo.schema.ts          # Zod validation schemas
│   ├── middleware/
│   │   ├── error-handler.ts
│   │   └── validate.ts
│   ├── types/
│   │   └── todo.types.ts
│   ├── lib/
│   │   └── prisma.ts               # Prisma client singleton
│   └── app.ts                      # Express app setup
├── tests/
│   ├── integration/
│   │   └── todo.test.ts
│   └── unit/
│       └── todo.service.test.ts
├── package.json
├── tsconfig.json
├── jest.config.ts
├── docker-compose.yml
└── .env.example
```

### Dev Setup
```bash
npm install
cp .env.example .env
docker compose up -d          # Start PostgreSQL
npx prisma migrate dev        # Run migrations
npm run dev                   # Start dev server
```

### Conventions
- **Files**: kebab-case with layer suffix (e.g., `todo.controller.ts`)
- **Code**: Layered architecture — controllers never access repositories directly
- **Tests**: Jest with `npm test`, integration tests use a test database

---

## Traceability

| Requirement | Component | API | Data |
|-------------|-----------|-----|------|
| US-001 Create Todo | TodoController, TodoService, TodoRepository | POST /api/todos | Todo |
| US-002 List Todos | TodoController, TodoService, TodoRepository | GET /api/todos | Todo |
| US-003 Update Todo | TodoController, TodoService, TodoRepository | PATCH /api/todos/:id | Todo |
| US-004 Delete Todo | TodoController, TodoService, TodoRepository | DELETE /api/todos/:id | Todo |
| US-005 Filter by Status | TodoController, TodoService, TodoRepository | GET /api/todos?status= | Todo |

---

## Operations

### Summary
- **Observability Level**: Minimal
- **Error Tracking**: Log-based only
- **Lifecycle Management**: Health + readiness + graceful shutdown

### Logging

**Strategy**: Structured JSON via pino + pino-http middleware

| Component | Key Log Events | Level |
|---|---|---|
| TodoController | Request received, validation failed, response sent | info, warn |
| TodoService | Todo created/updated/deleted, business rule applied | info |
| TodoRepository | Query executed, connection error | debug, error |
| Error Handler | Unhandled error caught | error |

**Correlation**: `X-Request-ID` header propagated (generated if absent).
**Sensitive Data**: No PII in this app (no auth). Log todo IDs but not full content on debug level.

### Health & Readiness

| Endpoint | Purpose | Checks |
|---|---|---|
| `GET /health` | Liveness | Process alive, returns `{"status":"ok","uptime":N}` |
| `GET /health/ready` | Readiness | PostgreSQL `SELECT 1` (2s timeout) |

Readiness returns `503` if database is unreachable.

### Graceful Shutdown

```
SIGTERM → stop accepting connections → wait for in-flight (30s) → disconnect Prisma → exit 0
```

- **Timeout**: 30s (env: `SHUTDOWN_TIMEOUT_MS`)
- **Signals**: SIGTERM, SIGINT

### Configuration Management

| Variable | Required | Default | Sensitive? | Description |
|---|---|---|---|---|
| `PORT` | No | 3000 | No | HTTP listen port |
| `NODE_ENV` | No | development | No | Runtime environment |
| `DATABASE_URL` | Yes | — | Yes | PostgreSQL connection string |
| `LOG_LEVEL` | No | info | No | Minimum log level (fatal/error/warn/info/debug) |
| `SHUTDOWN_TIMEOUT_MS` | No | 30000 | No | Graceful shutdown timeout |

**Startup validation**: Validate `DATABASE_URL` is present and is a valid PostgreSQL URI. Exit 1 with clear message if missing.

### Error Handling

| Category | HTTP Status | Log Level | Example |
|---|---|---|---|
| Client error | 4xx | warn | Validation failed, todo not found |
| Operational error | 5xx (retriable) | error | DB timeout, connection pool exhausted |
| Programming error | 5xx (bug) | error | Unhandled exception |

Error log format:
```json
{"level":"error","timestamp":"ISO","requestId":"uuid","error":{"name":"...","message":"...","code":"..."}}
```
