# Context Assessment — Output Template

Generate `{SPECS_DIR}/{feature}/context.md` with this structure.

**Brownfield**: Populate all sections from codebase analysis.
**Greenfield**: Populate Overview, Feature Impact, Recommendations. Mark detection sections as "N/A — greenfield project."

```markdown
# Context Assessment

## Summary
<!-- 10-line max. Downstream phases read ONLY this section. -->
- **Type**: [Greenfield/Brownfield]
- **Scope**: [new/feature/bugfix/refactor]
- **Stack**: [Primary language + framework, e.g. "TypeScript / Next.js / PostgreSQL"]
- **Architecture**: [Pattern, e.g. "Modular Monolith", "Layered MVC"]
- **Feature**: [1-sentence description]
- **Impact**: [New standalone / Extends existing / Cross-cutting]
- **Complexity**: [Low/Medium/High] — [story estimate] stories, [X] domains, [Y] user types
- **Recommendations**: Personas [Yes/No], Units [Yes/No], NFR [Yes/No]

## Project Overview
- **Type**: [Greenfield/Brownfield]
- **Assessment Date**: [ISO timestamp]

## Technology Stack
- **Languages**: [Detected or "N/A"]
- **Frameworks**: [Detected or "N/A"]
- **Build System**: [npm/maven/gradle or "N/A"]
- **Testing**: [Jest/Pytest/JUnit or "N/A"]
- **Infrastructure**: [AWS/Azure/GCP or "N/A"]

## Patterns & Conventions
[Brownfield only — omit for greenfield]

- **Architecture pattern**: [e.g., "Layered: routes → controllers → services → repositories"]
- **Data access**: [e.g., "Repository pattern with Prisma ORM"]
- **API response format**: [e.g., "Envelope: { data, error, meta }"]
- **Error handling**: [e.g., "Custom AppError class, caught by error middleware"]
- **Authentication**: [e.g., "JWT in Authorization header, auth middleware"]
- **Validation**: [e.g., "Zod schemas at route level"]
- **Logging**: [e.g., "Winston structured JSON with correlation ID"]

## Codebase Analysis
[Brownfield only — omit for greenfield]

**Entry Points**:

| Entry Point | Type | Description |
|-------------|------|-------------|
| [src/index.ts] | [API server] | [Express app, listens on PORT] |

**Module Dependencies**:
```
[Import graph showing how modules depend on each other]
```

**Key Abstractions**:

| Abstraction | Location | Purpose |
|-------------|----------|---------|
| [BaseController] | [src/core/] | [Common controller logic] |

**Data Flow**:
```
[Request lifecycle: middleware → handler → service → repository → database]
```

**Integration Points**: [External APIs, databases, services]

## Feature Impact

**Affected Areas**: [New standalone / Extends existing / Modifies behavior / Cross-cutting]

| Area | Impact | Reason |
|------|--------|--------|
| [Module/File] | [New/Modify/Extend] | [Why] |

## Recommendations

- Story Count: [Low (1-4) / Medium (5-10) / High (11+)]
- Domain Boundaries: [Detected domains]
- User Types: [Detected user types]
- Integration Points: [External systems]
- **Personas**: [Yes/No] — [Reason]
- **Units**: [Yes/No] — [Reason]
- **NFR**: [Yes/No] — [Reason]

## Scope

- **Detected scope**: [new/feature/bugfix/refactor]
- **Rationale**: [Why this scope was detected — keywords, workspace state, request nature]
- **Phases skipped**: [List phases that will be skipped for this scope, or "None — full workflow"]

## Recommended Workflow

[ASCII art workflow diagram tailored to this project's complexity and type.
Show the recommended path based on the recommendations above.
Use box-drawing characters (┌ ─ ┐ │ └ ┘ ├ ┤ ▼ ▲ →) for boxes and arrows.
Simple projects: Context → Requirements → Design → Tasks → Implement → Build and Test → Deploy.
Complex projects: add Decomposition, per-unit cycles (Design → Tasks → Implement), then Build and Test → Deploy.
See assess.md for diagram templates.]

## External References
[If external resources were used — otherwise omit]

| Source | Type | What was used |
|--------|------|---------------|
| [URL or doc path] | [Design / API spec / Documentation] | [What was extracted] |
```
