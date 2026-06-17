# Configuration & Environment — Output Template

**Path**: `{OUTPUT_DIR}/configuration.md`

~~~markdown
<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->
# Configuration & Environment

## Summary

[Brief characterization: config approach, number of env vars, environments detected, secrets management maturity.]

## Environment Variables

| Variable | Purpose | Module | Required | Default | Sensitive |
|---|---|---|---|---|---|
| [name] | [description] | [where consumed] | [yes/no] | [value or none] | [yes/no] |

## Configuration Files

| File | Purpose | Format | Environment-Specific |
|---|---|---|---|
| [path] | [description] | [JSON/YAML/TOML/env/properties] | [yes — how / no] |

## Feature Flags

| Flag | Purpose | Default | Location | Mechanism |
|---|---|---|---|---|
| [name] | [description] | [on/off] | [file:line or service] | [env var/config/remote service] |

## Environments Detected

| Environment | Config Source | Key Differences |
|---|---|---|
| [development] | [.env.development / config/dev.json] | [local DB, debug logging, mocked services] |
| [staging] | [.env.staging / config/staging.json] | [shared DB, reduced logging] |
| [production] | [.env.production / config/prod.json] | [production DB, error-only logging, real services] |

## Secrets Management

- **Approach**: [env vars / AWS Secrets Manager / Vault / config files / hardcoded]
- **Rotation Strategy**: [automated / manual / none detected]
- **Access Pattern**: [loaded at startup / fetched on demand / injected by platform]

## Configuration Patterns

- **Loading**: [how config is loaded — e.g., dotenv at startup, config module, DI container]
- **Validation**: [config validated at startup? schema? or fail-at-runtime?]
- **Overrides**: [how environment-specific values override defaults]
- **Location**: `[primary config loading file:line]`
~~~
