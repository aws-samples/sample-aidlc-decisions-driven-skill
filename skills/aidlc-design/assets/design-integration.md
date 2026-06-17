# Integration — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/integration.md`

## Structure

```yaml
sections:
  overview: integration strategy summary
  external_integrations: # per service
    - purpose, type (REST/GraphQL/gRPC/MQ), auth_method
    - key_endpoints, error_handling (retry/timeout/fallback)
  inter_unit_communication: # skip if single unit
    - pattern (sync REST / async events / mixed), transport
    sync_contracts: # if REST/gRPC between units
      - source → target, method, endpoint, request/response shapes
    domain_events: # if event-driven
      - name ("[domain].[entity].[action]"), producer, consumers, trigger, schema
    message_infrastructure: # if queues/event bus
      - queue/topic, purpose, producers, consumers, DLQ, retry, format, ordering
  integration_testing: strategy, mocking approach, contract testing tool
```

## Rules
- Every external system from requirements must appear
- Error handling mandatory for each integration (no silent failures)
- Events must have schema definitions
