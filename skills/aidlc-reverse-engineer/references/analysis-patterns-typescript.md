# Analysis Patterns: TypeScript / JavaScript (Node.js)

**Config files**: `package.json`, `tsconfig.json`, `.eslintrc.*`, `jest.config.*`, `vitest.config.*`
**Entry points**: `src/index.ts`, `src/main.ts`, `src/app.ts`, `src/server.ts`, `bin/`
**Frameworks**: Express (`app.get/post/use`), NestJS (`@Controller`, `@Module`, `@Injectable`), Fastify (`fastify.route`), Next.js (`pages/`, `app/`), Hono (`app.get`), Koa (`router.get`), Remix (`loader`/`action`), Nuxt.js (`server/api/`), SvelteKit (`+server.ts`, `+page.server.ts`), Astro (`src/pages/`)
**ORM/DB**: Prisma (`schema.prisma`), TypeORM (`@Entity`, `@Column`), Drizzle (`pgTable`), Mongoose (`Schema`, `model`), Knex (`knex.migrate`), Sequelize (`define`, `Model.init`), MikroORM (`@Entity`)
**Route detection**: Express `router.get/post`, NestJS `@Get/@Post`, Fastify `fastify.get`, file-based routing (`pages/`, `app/`, `server/api/`)
**Business logic signals**: Service classes, `validate*` functions, `calculate*` functions, enum-based state machines, Zod/Joi schemas
**Test patterns**: Jest/Vitest `describe/it/expect`, `__tests__/`, `*.test.ts`, `*.spec.ts`

## Business Rule Extraction Heuristics

| Signal | What It Indicates |
|---|---|
| `if/switch` on status/state fields | State machine or workflow |
| Validation functions with error returns | Business validation rules |
| Functions named `calculate*`, `compute*`, `derive*` | Business calculations |
| Role/permission checks before operations | Authorization rules |
| Assertions or guard clauses at function start | Invariants |
| Cron/scheduler configurations | Scheduled business processes |
| Event handlers / message consumers | Event-driven business logic |
| Constants with business meaning (rates, limits, thresholds) | Business parameters |
| Enum types with domain names | Domain concepts / state definitions |
