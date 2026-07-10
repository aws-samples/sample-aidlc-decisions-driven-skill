# Technology & Conventions

## Summary
- **Stack**: TypeScript 5.x / Express 4.x / PostgreSQL 16 / Prisma 5.x
- **Architecture**: Layered (Controller → Service → Repository)
- **API**: REST, JSON, standard HTTP status codes

## Stack

| Layer | Technology | Version |
|---|---|---|
| Language | TypeScript | 5.x |
| Runtime | Node.js | 20 LTS |
| Framework | Express | 4.x |
| ORM | Prisma | 5.x |
| Database | PostgreSQL | 16 |
| Validation | Zod | 3.x |
| Testing | Jest + supertest | Latest |

## Architecture

- **Pattern**: Layered (routes → controllers → services → repositories)
- **API Style**: REST with standard HTTP verbs and status codes
- **Error Format**: `{ "error": { "code": "string", "message": "string" } }`

## Conventions

- **Files**: kebab-case with layer suffix (e.g., `todo.controller.ts`)
- **Code**: Controllers never access repositories directly
- **Testing**: Jest with `npm test`, integration tests use a test database
- **Validation**: Zod schemas for all request input
- **Error Handling**: Centralized error middleware, never leak stack traces
