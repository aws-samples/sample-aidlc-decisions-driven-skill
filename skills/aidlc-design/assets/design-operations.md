# Operations Design — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/operations.md`

Generated when D3 includes observability/operations questions AND answer is not "None/Skip." Always generated for `new` and `feature` scope unless explicitly skipped.

## Structure

```markdown
# Operations Design

## Summary
- **Observability Level**: [Minimal / Standard / Full — from D3]
- **Error Tracking**: [Log-based / Dedicated service / Custom — from D3]
- **Lifecycle Management**: [Basic / Container-ready / Full — from D3]
- **Logging Format**: [Structured JSON / Plain text]
- **Logging Library**: [from stack — pino, winston, structlog, slog, SLF4J, etc.]

---

## Logging

### Strategy
- **Format**: [structured JSON for production, human-readable for dev]
- **Library**: [chosen per stack ecosystem]
- **Levels**: error, warn, info, debug
- **Correlation**: [request-id header propagation — generate if not present, forward if received]
- **Sampling**: [none for error/warn, configurable for info/debug in high-traffic]

### Per-Component Logging

| Component | Key Log Events | Level | Context Fields |
|---|---|---|---|
| [per design/components.md] | [events worth logging] | [level] | [fields to include] |

### Sensitive Data Rules
- **Never log**: passwords, tokens, API keys, full credit card numbers, SSNs
- **Mask**: email (first 3 + domain), phone (last 4 digits), IP (last octet)
- **Always include**: request-id, timestamp, duration, user-id (if authed), operation name

---

## Health & Readiness

### Endpoints

| Endpoint | Purpose | Authentication | Response |
|---|---|---|---|
| `GET /health` | Liveness — process alive? | None (internal only) | `200 {"status":"ok","uptime":N}` or `503` |
| `GET /health/ready` | Readiness — can serve traffic? | None (internal only) | `200 {"status":"ready","checks":{...}}` or `503 {"status":"not_ready","failures":[...]}` |

### Readiness Checks

| Dependency | Check Method | Timeout | On Failure |
|---|---|---|---|
| [per design/integration.md + data layer] | [query/ping/HEAD] | [1-3s] | [503 / degrade gracefully] |

### Response Schema
```json
{
  "status": "ready | not_ready",
  "uptime": 12345,
  "checks": {
    "database": { "status": "ok", "latency_ms": 2 },
    "cache": { "status": "ok", "latency_ms": 1 }
  },
  "version": "1.0.0"
}
```

---

## Graceful Shutdown

### Sequence
```
SIGTERM received
  1. Stop accepting new connections (close server listener)
  2. Set health endpoint to return 503 (signal load balancer to drain)
  3. Wait for in-flight requests to complete (timeout: configurable, default 30s)
  4. Close database connection pool
  5. Close cache/queue connections
  6. Flush pending logs/metrics
  7. Exit 0

On timeout exceeded:
  → Log warning with count of abandoned requests
  → Force close remaining connections
  → Exit 1
```

### Configuration
| Setting | Default | Env Variable |
|---|---|---|
| Shutdown timeout | 30s | `SHUTDOWN_TIMEOUT_MS` |
| Drain delay | 5s | `DRAIN_DELAY_MS` |

---

## Metrics (if observability ≥ Standard)

### Key Metrics

| Metric Name | Type | Labels | Purpose |
|---|---|---|---|
| `http_requests_total` | Counter | method, path, status_code | Request volume and error rates |
| `http_request_duration_seconds` | Histogram | method, path | Latency distribution (p50, p95, p99) |
| `http_requests_in_flight` | Gauge | — | Current concurrency |
| `db_query_duration_seconds` | Histogram | operation, table | Database performance |
| `db_pool_connections` | Gauge | state (active/idle/waiting) | Connection pool health |
| `external_call_duration_seconds` | Histogram | service, operation | External dependency latency |
| `external_call_errors_total` | Counter | service, error_type | External dependency failures |

### Instrumentation Points

| Component | What to Measure | Cardinality Notes |
|---|---|---|
| HTTP middleware | Request count, duration, status, in-flight | Normalize path params (`:id` not actual IDs) |
| Repository layer | Query duration, error rate per operation | Label by operation name, not query text |
| External calls | Duration, success/failure, retry count | Label by service name |
| Business logic | Domain event counts | Low cardinality — event type only |

### Exposition
- **Endpoint**: `GET /metrics` (Prometheus format) or push-based (OTLP)
- **Scrape interval**: 15s (standard)
- **Retention**: [per deployment platform]

---

## Error Handling & Reporting

### Error Classification

| Category | HTTP Status | Log Level | Alert? | Retry? | Example |
|---|---|---|---|---|---|
| Client error | 4xx | warn | No | No | Validation failed, not found, unauthorized |
| Operational error | 5xx (retriable) | error | Threshold | Yes | DB timeout, external API 503 |
| Programming error | 5xx (bug) | error | Immediate | No | Null reference, unhandled promise rejection |
| Fatal error | — | fatal | Page | No | Cannot connect to DB on startup, OOM |

### Error Log Structure
```json
{
  "level": "error",
  "timestamp": "ISO8601",
  "requestId": "uuid",
  "error": {
    "name": "ErrorClassName",
    "message": "Human-readable description",
    "code": "MACHINE_READABLE_CODE",
    "stack": "[included only in non-production]"
  },
  "context": {
    "operation": "ComponentName.methodName",
    "userId": "[if authenticated]",
    "input": "[sanitized relevant input]",
    "duration_ms": 5000
  }
}
```

### Error Tracking (if dedicated service selected)
- **Service**: [Sentry / Datadog / Rollbar / etc.]
- **Capture**: All unhandled exceptions + operational errors
- **Context enrichment**: request-id, user-id, request path, environment
- **Source maps**: Upload on deploy for stack trace deobfuscation
- **Alert rules**: [per error type classification above]

---

## Configuration Management

### Required Environment Variables

| Variable | Required | Default | Sensitive? | Description |
|---|---|---|---|---|
| `PORT` | No | 3000 | No | HTTP listen port |
| `NODE_ENV` / `APP_ENV` | No | development | No | Runtime environment |
| `LOG_LEVEL` | No | info | No | Minimum log level |
| `DATABASE_URL` | Yes | — | Yes | Primary database connection |
| `SHUTDOWN_TIMEOUT_MS` | No | 30000 | No | Graceful shutdown timeout |
| [per integration.md] | [Yes/No] | [default] | [Yes/No] | [description] |

### Startup Validation
On process start, before accepting traffic:
1. Validate ALL required env vars present (exit 1 with clear message if missing)
2. Validate format of known vars (DATABASE_URL is valid URI, PORT is numeric, etc.)
3. Attempt initial connections (DB, cache, external services)
4. If critical dependency unreachable: exit 1 with diagnostic message
5. If non-critical dependency unreachable: log warning, start in degraded mode

---

## Alerting (if observability = Full)

### Alert Rules

| Alert | Condition | Severity | Action |
|---|---|---|---|
| High error rate | 5xx rate > 1% for 5 min | Warning | Notify on-call |
| Critical error rate | 5xx rate > 5% for 2 min | Critical | Page on-call |
| High latency | p99 > [SLA target] for 5 min | Warning | Notify on-call |
| Health check failure | /health/ready returns 503 for 30s | Critical | Auto-restart + page |
| Database connection pool exhausted | idle connections = 0 for 1 min | Warning | Scale or investigate |

### Notification Channels
| Severity | Channel | Escalation |
|---|---|---|
| Info | Slack/Teams channel | None |
| Warning | Slack/Teams + ticket created | Team lead after 30 min |
| Critical | PagerDuty/OpsGenie + Slack | Escalate after 15 min |

---

## Traceability

| Operations Concern | Related Design Artifacts |
|---|---|
| Per-component logging | design/components.md |
| Readiness check targets | design/integration.md, design/data-model.md |
| Error classification | design/api-spec.md (error responses) |
| Configuration variables | design/implementation.md (env setup) |
| Metrics instrumentation | design/components.md, design/api-spec.md |
```

---

## Rules

- Logging library and patterns must match the stack chosen in D3
- Per-component logging table must reference ALL components from `design/components.md`
- Readiness checks must cover ALL critical dependencies from `design/integration.md` and the primary database
- Configuration variables must include ALL secrets/env vars referenced in `design/implementation.md`
- Error classification must be consistent with error response format in `design/api-spec.md`
- Metrics endpoint path must not conflict with API routes in `design/api-spec.md`
- Health endpoint paths must not conflict with API routes
- If observability level = "Minimal": include only Logging + Health + Graceful Shutdown + Configuration sections
- If observability level = "Standard": add Metrics section
- If observability level = "Full": add Alerting section
- Use `[TBD - not decided in D3]` for any operational aspect not determinable from current decisions
