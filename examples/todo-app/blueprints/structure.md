# Project Structure

## Summary
- **Root**: `todo-app/`
- **Source**: `src/` with layered subdirectories
- **Tests**: `tests/` with unit and integration separation
- **Database**: `prisma/` for schema and migrations

## Directory Layout

```
todo-app/
├── prisma/
│   ├── schema.prisma              # Database schema
│   └── migrations/                # Prisma migrations
├── src/
│   ├── controllers/
│   │   └── todo.controller.ts     # HTTP request handlers
│   ├── services/
│   │   └── todo.service.ts        # Business logic
│   ├── repositories/
│   │   └── todo.repository.ts     # Data access (Prisma)
│   ├── routes/
│   │   └── todo.routes.ts         # Express router
│   ├── schemas/
│   │   └── todo.schema.ts         # Zod validation schemas
│   ├── middleware/
│   │   ├── error-handler.ts       # Global error handler
│   │   └── validate.ts            # Validation middleware
│   ├── types/
│   │   └── todo.types.ts          # Shared TypeScript types
│   ├── lib/
│   │   └── prisma.ts              # Prisma client singleton
│   └── app.ts                     # Express app setup
├── tests/
│   ├── integration/
│   │   └── todo.test.ts           # API integration tests
│   └── unit/
│       ├── todo.repository.test.ts
│       └── todo.service.test.ts
├── package.json
├── tsconfig.json
├── jest.config.ts
├── docker-compose.yml
├── Dockerfile
├── .env.example
└── .github/
    └── workflows/
        └── deploy.yml             # CI/CD pipeline
```

## Key Files

| File | Purpose |
|---|---|
| `src/app.ts` | Express app entry point, middleware setup |
| `prisma/schema.prisma` | Database schema (Todo model) |
| `src/lib/prisma.ts` | Prisma client singleton |
| `docker-compose.yml` | Local PostgreSQL for development |
| `Dockerfile` | Production container build |
| `.github/workflows/deploy.yml` | CI/CD pipeline |
