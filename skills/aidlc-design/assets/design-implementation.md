# Implementation — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/implementation.md`

Engineer's reference for project scaffold and daily development.

## Structure

```yaml
sections:
  code_organization:
    - architecture_pattern, repository_type (from D3)
    - directory_structure: annotated tree
    - module_boundaries, naming_conventions
  technology_stack:
    - key_dependencies (with versions), monorepo_config (if applicable)
  development_setup:
    - prerequisites, setup_commands, env_variables (name/description/example)
  testing:
    - unit/integration/e2e/pbt: framework + run command
    - coverage_target
```

## Rules
- Directory structure must match architecture pattern from D3
- All dependencies must be specific versions (not "latest")
- Setup commands must work from a fresh clone
- Env variable examples must use safe placeholder values (not real secrets)
