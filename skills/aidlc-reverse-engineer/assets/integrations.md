# Integrations — Output Template

**Path**: `{OUTPUT_DIR}/integrations.md`

~~~markdown
<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->
# Integrations

## Summary

[detected] external integrations identified. [Brief characterization of integration patterns and reliability posture.]

## Integrations

| Service | Protocol | Direction | Data Flow | Error Handling |
|---|---|---|---|---|
| [name] | [REST/gRPC/SDK/queue/webhook] | [inbound/outbound/bidirectional] | [description] | [retry/fallback/circuit-breaker/none] |

## Integration Details

### [Service Name]

- **Protocol**: [detected]
- **Direction**: [inbound/outbound/bidirectional]
- **Config**: `[file:line]`

#### Endpoints Called

| Method | URL/Topic | Purpose |
|---|---|---|
| [GET/POST/publish/subscribe] | [url or topic] | [description] |

#### Retry & Fallback

- **Retry**: [strategy or none]
- **Fallback**: [behavior or none]
- **Timeout**: [value or none]

#### Environment Variables

| Variable | Purpose | Required |
|---|---|---|
| [name] | [description] | [yes/no] |
~~~
