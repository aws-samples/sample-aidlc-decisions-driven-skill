# Infrastructure & Deployment — Output Template

**Path**: `{OUTPUT_DIR}/infrastructure.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: hosting approach, CI/CD maturity, containerization, IaC coverage
  containerization:
    - services: table (component, dockerfile, base image, multi-stage, health check)
    - docker_compose: file path, services, volumes, networks
  cicd_pipeline:
    - stages: table (stage, tool, config file, description)
    - characteristics: trigger, environments, approval gates, artifacts, duration
  infrastructure_as_code:
    - tools: table (tool, files, resources managed)
    - cloud_resources: table (name, type, purpose, config location)
  hosting_runtime:
    - platform, compute, database, cache, queue/events, storage, CDN
  database_management:
    - migration tool, location, count, seed data, backup strategy
  monitoring_observability:
    - table: aspect (logging/metrics/tracing/alerting/error tracking), tool, config, coverage
```

## Rules
- Detect from actual config files (Dockerfiles, CI configs, IaC), not assumptions
- Report "none" or "not detected" when infrastructure is absent — don't guess
