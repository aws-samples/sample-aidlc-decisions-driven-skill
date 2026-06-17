# Technology Catalog — Backend & Data

> Load ONLY if system has backend services.
> **Stack filtering**: When `context-summary.stack` is known, present ONLY options from the matching ecosystem. Skip categories irrelevant to the detected language/runtime.

## Backend Stack

- **Backend Language & Runtime**: Node.js, Python, Java, Go, .NET, Ruby
- **Backend Framework**: Express, NestJS, FastAPI, Spring Boot, Gin, etc.
- **API Design Pattern**: REST, GraphQL, gRPC, tRPC, hybrid
- **API Documentation**: OpenAPI/Swagger, GraphQL schema, gRPC proto, none
- **Validation Library**: Joi, Zod, class-validator, Pydantic, other
- **Logging Framework**: Winston, Pino, Bunyan, Python logging, Log4j
- **Error Handling Approach**: Middleware-based, try-catch, Result types, other

## Data Layer

- **Database Technology**: PostgreSQL, MySQL, MongoDB, DynamoDB, etc.
- **Database ORM/Client**: Prisma, TypeORM, Sequelize, Mongoose, raw SQL
- **Migration Tool**: Prisma Migrate, TypeORM migrations, Flyway, Liquibase
- **Caching Strategy**: Redis, Memcached, in-memory, CDN, none for MVP
- **Search Technology**: Elasticsearch, Algolia, database full-text, Typesense, none

## Authentication & Security

- **Authentication Method**: JWT, OAuth 2.0, Session-based, API keys, none (public)
- **Authorization Model**: RBAC, ABAC, simple roles, none
- **Password Hashing**: bcrypt, Argon2, scrypt (if applicable)
- **Security Headers**: Helmet.js, custom middleware, framework defaults

## Testing Strategy

- **Unit Test Framework**: Jest, Vitest, Pytest, JUnit, Go testing, Mocha
- **Integration Test Approach**: Supertest, TestContainers, in-memory DB, test environment
- **E2E Test Framework**: Playwright, Cypress, Selenium, Puppeteer, none for MVP
- **API Testing**: Postman, REST Client, Insomnia, automated tests, none
- **Load Testing**: k6, JMeter, Gatling, Locust, none for MVP
- **Correctness & Property-Based Testing** (MANDATORY): How to verify correctness properties

## Code Organization

- **Architecture Pattern**: Layered, Clean Architecture, Hexagonal, Feature-based, MVC
- **Code Style Enforcement**: ESLint, Prettier, Black, Checkstyle, none

## Repository Structure

- **Repository Strategy**: Monorepo, Multi-repo, Single repo
- **Monorepo Tool** (if monorepo): Nx, Turborepo, Lerna, Rush, Bazel, pnpm workspaces, none
- **Package Manager**: npm, yarn, pnpm, bun (JS/TS); pip, poetry, uv (Python); Maven, Gradle (Java); Go modules (Go)
- **Branch Strategy**: Git Flow, GitHub Flow, Trunk-based development, custom

## Configuration & Environment

- **Configuration Management**: Environment variables, config files, AWS Parameter Store, Secrets Manager
- **Secret Management**: AWS Secrets Manager, HashiCorp Vault, environment variables, config files
- **Environment Strategy**: Dev/Staging/Prod separation, feature flags, blue-green
