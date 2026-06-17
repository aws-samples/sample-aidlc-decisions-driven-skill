# Architecture Patterns & Directory Structures

Reference guide for common architecture patterns and their directory structures.

## Monolithic Application

**When to use**: Simple projects, single team, low complexity

```
src/
├── api/              # Controllers, routes, middleware
├── domain/           # Business logic, services
├── infrastructure/   # Database, external services
├── shared/           # Utilities, types, constants
└── config/           # Configuration
```

## Modular Monolith

**When to use**: Medium complexity, multiple teams, clear domain boundaries

```
src/
├── modules/
│   ├── user-management/
│   │   ├── api/
│   │   ├── domain/
│   │   └── infrastructure/
│   ├── product-catalog/
│   └── order-processing/
├── shared/           # Shared across modules
└── config/
```

## Microservices

**When to use**: High complexity, multiple teams, independent deployment needed

```
services/
├── user-service/
│   ├── src/
│   ├── tests/
│   └── Dockerfile
├── product-service/
├── order-service/
└── shared/           # Shared libraries
```

## Serverless

**When to use**: Event-driven, variable load, pay-per-use

```
functions/
├── user-api/
│   ├── handler.ts
│   └── domain/
├── product-api/
└── order-processor/
layers/               # Shared code
└── common/
```

## Frontend Application

**When to use**: React/Vue/Angular applications

```
src/
├── components/       # Reusable UI components
├── pages/            # Page components
├── features/         # Feature modules
├── services/         # API clients
├── store/            # State management
├── hooks/            # Custom hooks
└── utils/            # Utilities
```

## Monorepo

**When to use**: Multiple related packages, shared code

```
packages/
├── frontend/
├── backend/
├── shared-types/
├── ui-components/
└── common-utils/
```

## Module Boundaries

### Layered Architecture
- API → Domain → Infrastructure
- Domain should not depend on infrastructure
- API depends on domain only

### Modular Monolith
- Modules communicate via public APIs only
- No direct database access across modules
- Each module owns its data

### Microservices
- Services are independently deployable
- Database per service pattern
- Communicate via APIs or events

### Serverless
- Functions are single-purpose and stateless
- Shared code in Lambda layers
- Optimize for cold start

---

## Repository Structure

### Single Repository (Monolith)
One repo, one application, all code together.

**Pros**: Simple, easy refactoring, atomic commits, single deployment
**Cons**: Can become large, harder to enforce boundaries, all-or-nothing deployment
**When to use**: Small-medium projects, single team, tightly coupled code

### Monorepo (Multiple Packages, One Repo)
Multiple packages/apps in one repository with shared tooling.

**Pros**: Easy code sharing, atomic cross-package changes, consistent tooling, single source of truth
**Cons**: Requires tooling, complex CI/CD, larger repo size
**When to use**: Multiple related apps, shared code, coordinated releases, single org

**Structure**:
```
monorepo/
├── apps/
│   ├── web/              # Web frontend
│   ├── mobile/           # Mobile app
│   └── api/              # Backend API
├── packages/
│   ├── ui-components/    # Shared UI
│   ├── shared-types/     # Types
│   └── utils/            # Utilities
├── package.json          # Root with workspaces
└── turbo.json            # Monorepo tool config
```

### Multi-Repo (Multiple Repositories)
Each service/app in its own repository.

**Pros**: Clear ownership, independent deployment, team autonomy, smaller repos
**Cons**: Harder to share code, coordinating changes, multiple CI/CD
**When to use**: Microservices, independent teams, different release cycles

**Structure**:
```
Repositories:
- user-service/
- product-service/
- order-service/
- shared-lib/ (published to registry)
```

---

## Monorepo Tools

- **Nx**: Large monorepos, build optimization, caching
- **Turborepo**: JS/TS monorepos, speed, remote caching
- **pnpm Workspaces**: Simple monorepos, fast installs
- **Yarn Workspaces**: Node.js monorepos, established
- **Lerna**: Publishing packages, versioning
- **Bazel**: Very large, polyglot projects

---

## Repository Decision Factors

| Factor | Single Repo | Monorepo | Multi-Repo |
|--------|-------------|----------|------------|
| Team Size | 1-5 | 5-50 | 10+ |
| Number of Apps | 1 | 2-10 | 3+ |
| Code Sharing | High | High | Low-Medium |
| Deployment Independence | Low | Medium | High |
| Setup Complexity | Low | Medium | High |

**Choose Single Repo**: Small-medium project, single team, tightly coupled
**Choose Monorepo**: Multiple related apps, frequent code sharing, coordinated releases
**Choose Multi-Repo**: Microservices, independent teams, different release cycles

---

## Best Practices

### Monorepo
1. Use monorepo tool (Nx, Turborepo)
2. Define clear package boundaries
3. Avoid circular dependencies
4. Share configs at root
5. Implement affected detection for CI/CD
6. Cache build artifacts
7. Use path aliases for imports

### Multi-Repo
1. Publish shared libraries to registry
2. Version libs semantically
3. Automate dependency updates
4. Maintain API contracts
5. Use API versioning
6. Document service dependencies
