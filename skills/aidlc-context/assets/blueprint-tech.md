# Blueprint: Tech — Output Template

Generate `{BLUEPRINTS_DIR}/tech.md` (canonical, platform-agnostic — no front-matter; the platform shim references it).

**Progressive enrichment**: Phase 1 creates (detected or placeholders), Phase 4 updates with D3 decisions.
**If file already exists**: Preserve all existing content. Only update placeholders. Never remove settled decisions.

## Structure

```yaml
sections:
  summary: # 3-line max
    - stack (language/framework/DB), architecture/API style, infra
  stack:
    - languages, frameworks, build_system, package_manager, testing
    # Brownfield: detect. Greenfield: "Pending D3 decisions"
  architecture:
    - pattern: Monolith/Microservices/Serverless/"Pending D2/D3"
    - api_style: REST/GraphQL/gRPC/"Pending D3"
  infrastructure:
    - cloud_provider, compute, database, iac_tool
    # Brownfield: detect. Greenfield: "Pending D3"
  patterns_conventions: # how tools are used, not just what they are
    - architecture_pattern: e.g. "Layered: routes → controllers → services → repos"
    - data_access: e.g. "Repository pattern with Prisma ORM"
    - api_response_format: e.g. "Envelope: { data, error, meta }"
    - error_handling: e.g. "Custom AppError class, caught by middleware"
    - authentication: e.g. "JWT in Authorization header"
    - validation: e.g. "Zod schemas at route level"
    - logging: e.g. "Winston structured JSON with correlation ID"
    - code_style: detected from linter configs
    - naming_conventions: detected from code
    - branch_strategy: detected from git
    # Brownfield: detect from source. Greenfield: "Will be defined during design phase"
  environment_configuration:
    - config_approach, environments, secrets_management
  cicd_pipeline:
    - tool, stages, deploy_target
  dependency_management:
    - lockfile, version_strategy, monorepo_tooling
  known_technical_debt: # Brownfield only
    - bullet list of fragile/deprecated/attention areas
```

## Rules
- Brownfield: detect from config files AND source code patterns
- Greenfield: use "Pending D3/D2 decisions" placeholders
- Phase 4 (design) fills placeholders with D3 choices — never overwrites settled values
