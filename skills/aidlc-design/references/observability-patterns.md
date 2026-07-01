# Observability Patterns — Reference by Ecosystem

> **Usage**: Load this reference during `design/operations.md` generation. Read ONLY the section matching the project's primary stack from D3. Do not load irrelevant ecosystems.

---

## Node.js / TypeScript

### Logging

| Library | Best For | Structured JSON | Performance | Notes |
|---|---|---|---|---|
| pino | Production services | Yes (native) | Fastest (low overhead) | Recommended default for APIs |
| winston | Feature-rich needs | Yes (via format) | Moderate | Transport ecosystem, but heavier |
| bunyan | Legacy/compatibility | Yes (native) | Good | Less maintained, pino is spiritual successor |

**Recommended pattern**: pino + pino-http middleware

```typescript
// Logger setup
import pino from 'pino';
export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  ...(process.env.NODE_ENV === 'development' && { transport: { target: 'pino-pretty' } })
});

// Request logging middleware
import pinoHttp from 'pino-http';
export const requestLogger = pinoHttp({
  logger,
  genReqId: (req) => req.headers['x-request-id'] || crypto.randomUUID(),
  customProps: (req) => ({ userId: req.user?.id }),
  redact: ['req.headers.authorization', 'req.headers.cookie']
});
```

### Metrics

| Library | Protocol | Best For |
|---|---|---|
| prom-client | Prometheus pull | Standard Prometheus/Grafana setups |
| @opentelemetry/sdk-metrics | OTLP push/pull | OpenTelemetry-native environments |

**Recommended pattern**: prom-client with default metrics + custom histograms

```typescript
import { collectDefaultMetrics, Histogram, Registry } from 'prom-client';
const register = new Registry();
collectDefaultMetrics({ register });

export const httpDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5],
  registers: [register]
});
```

### Health Checks

```typescript
// Minimal health
app.get('/health', (req, res) => res.json({ status: 'ok', uptime: process.uptime() }));

// Readiness with dependency checks
app.get('/health/ready', async (req, res) => {
  const checks: Record<string, { status: string; latency_ms?: number }> = {};
  
  // Database check
  const dbStart = Date.now();
  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = { status: 'ok', latency_ms: Date.now() - dbStart };
  } catch {
    checks.database = { status: 'failed' };
  }
  
  const allOk = Object.values(checks).every(c => c.status === 'ok');
  res.status(allOk ? 200 : 503).json({ status: allOk ? 'ready' : 'not_ready', checks });
});
```

### Graceful Shutdown

```typescript
export function setupGracefulShutdown(server: Server, cleanup: () => Promise<void>) {
  let isShuttingDown = false;
  const timeout = parseInt(process.env.SHUTDOWN_TIMEOUT_MS || '30000', 10);

  const shutdown = async (signal: string) => {
    if (isShuttingDown) return;
    isShuttingDown = true;
    logger.info({ signal }, 'Shutdown initiated');

    server.close(async () => {
      await cleanup();
      logger.info('Shutdown complete');
      process.exit(0);
    });

    setTimeout(() => {
      logger.warn('Forced shutdown — timeout exceeded');
      process.exit(1);
    }, timeout);
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}
```

### Error Tracking Integration

| Service | SDK | Setup |
|---|---|---|
| Sentry | @sentry/node | `Sentry.init({ dsn, tracesSampleRate: 0.1 })` — init before other imports |
| Datadog | dd-trace | `require('dd-trace').init()` — must be first import |
| Rollbar | rollbar | `new Rollbar({ accessToken, environment })` |

### Configuration Validation

```typescript
import { z } from 'zod';

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  DATABASE_URL: z.string().url(),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),
});

export const config = envSchema.parse(process.env);
// Throws with clear validation errors on startup if invalid
```

---

## Python

### Logging

| Library | Best For | Structured JSON | Notes |
|---|---|---|---|
| structlog | Production services | Yes (native) | Recommended — context binding, processors |
| python-json-logger | Simple JSON logging | Yes (formatter) | Lightweight addition to stdlib logging |
| loguru | Developer ergonomics | Yes (via serialize) | Convenient but less composable |

**Recommended pattern**: structlog with stdlib integration

```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.JSONRenderer() if ENV == "production"
        else structlog.dev.ConsoleRenderer(),
    ],
    wrapper_class=structlog.make_filtering_bound_logger(LOG_LEVEL),
)
logger = structlog.get_logger()

# Request-id binding (FastAPI middleware)
@app.middleware("http")
async def add_request_id(request: Request, call_next):
    request_id = request.headers.get("x-request-id", str(uuid4()))
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(request_id=request_id)
    response = await call_next(request)
    response.headers["x-request-id"] = request_id
    return response
```

### Metrics

| Library | Protocol | Best For |
|---|---|---|
| prometheus-client | Prometheus pull | Standard setups |
| opentelemetry-sdk | OTLP | OpenTelemetry-native |

### Health Checks

```python
# FastAPI
@app.get("/health")
async def health():
    return {"status": "ok", "uptime": time.time() - START_TIME}

@app.get("/health/ready")
async def readiness():
    checks = {}
    try:
        await db.execute(text("SELECT 1"))
        checks["database"] = {"status": "ok"}
    except Exception:
        checks["database"] = {"status": "failed"}
    
    all_ok = all(c["status"] == "ok" for c in checks.values())
    status_code = 200 if all_ok else 503
    return JSONResponse(
        status_code=status_code,
        content={"status": "ready" if all_ok else "not_ready", "checks": checks}
    )
```

### Graceful Shutdown

```python
# FastAPI/Uvicorn handles SIGTERM natively
# Add cleanup via lifespan:
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await db.connect()
    yield
    # Shutdown
    logger.info("Shutting down...")
    await db.disconnect()
    logger.info("Shutdown complete")

app = FastAPI(lifespan=lifespan)
```

### Configuration Validation

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    port: int = 8000
    database_url: str  # required — fails on startup if missing
    log_level: str = "info"
    environment: str = "development"
    shutdown_timeout: int = 30

    class Config:
        env_file = ".env"

settings = Settings()  # Raises ValidationError with clear messages
```

---

## Java / Kotlin (Spring Boot)

### Logging

| Library | Best For | Notes |
|---|---|---|
| SLF4J + Logback | Standard Spring Boot | Built-in, structured via logstash-logback-encoder |
| Log4j2 | High-performance needs | Async loggers, lower allocation |

**Recommended pattern**: SLF4J + logstash-logback-encoder for JSON output

```xml
<!-- logback-spring.xml -->
<configuration>
  <springProfile name="production">
    <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
      <encoder class="net.logstash.logback.encoder.LogstashEncoder">
        <includeMdcKeyName>requestId</includeMdcKeyName>
        <includeMdcKeyName>userId</includeMdcKeyName>
      </encoder>
    </appender>
  </springProfile>
</configuration>
```

### Metrics

Spring Boot Actuator with Micrometer — auto-configured for Prometheus, Datadog, CloudWatch.

```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health, metrics, prometheus
  metrics:
    tags:
      application: ${spring.application.name}
```

### Health Checks

Spring Boot Actuator provides health endpoints out of the box:
- `/actuator/health` — liveness
- `/actuator/health/readiness` — readiness (with auto-detected DB, Redis, etc.)

Custom checks:
```kotlin
@Component
class ExternalApiHealthIndicator(private val client: WebClient) : HealthIndicator {
    override fun health(): Health {
        return try {
            client.get().uri("/ping").retrieve().toBodilessEntity().block(Duration.ofSeconds(2))
            Health.up().build()
        } catch (e: Exception) {
            Health.down(e).build()
        }
    }
}
```

### Graceful Shutdown

```yaml
# application.yml — Spring Boot 2.3+
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```

---

## Go

### Logging

| Library | Best For | Notes |
|---|---|---|
| slog (stdlib) | Go 1.21+ | Recommended — structured, zero-dep, fast |
| zerolog | Maximum performance | Zero allocation JSON logger |
| zap | High-performance structured | Uber's logger, battle-tested |

**Recommended pattern**: slog (stdlib, Go 1.21+)

```go
logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
    Level: slog.LevelInfo,
}))
slog.SetDefault(logger)

// Request middleware
func RequestLogger(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        requestID := r.Header.Get("X-Request-ID")
        if requestID == "" {
            requestID = uuid.NewString()
        }
        ctx := context.WithValue(r.Context(), "requestID", requestID)
        logger := slog.With("requestId", requestID)
        start := time.Now()
        next.ServeHTTP(w, r.WithContext(ctx))
        logger.Info("request", "method", r.Method, "path", r.URL.Path, "duration_ms", time.Since(start).Milliseconds())
    })
}
```

### Metrics

| Library | Protocol | Notes |
|---|---|---|
| prometheus/client_golang | Prometheus | Standard Go Prometheus client |
| go.opentelemetry.io/otel | OTLP | Full OpenTelemetry SDK |

### Health Checks

```go
func healthHandler(w http.ResponseWriter, r *http.Request) {
    json.NewEncoder(w).Encode(map[string]any{"status": "ok", "uptime": time.Since(startTime).Seconds()})
}

func readinessHandler(db *sql.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
        defer cancel()
        if err := db.PingContext(ctx); err != nil {
            w.WriteHeader(http.StatusServiceUnavailable)
            json.NewEncoder(w).Encode(map[string]any{"status": "not_ready", "error": err.Error()})
            return
        }
        json.NewEncoder(w).Encode(map[string]any{"status": "ready"})
    }
}
```

### Graceful Shutdown

```go
func main() {
    srv := &http.Server{Addr: ":8080", Handler: router}
    go func() { srv.ListenAndServe() }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()
    if err := srv.Shutdown(ctx); err != nil {
        slog.Error("forced shutdown", "error", err)
    }
    db.Close()
    slog.Info("shutdown complete")
}
```

### Configuration Validation

```go
// Using envconfig or viper
type Config struct {
    Port        int    `envconfig:"PORT" default:"8080"`
    DatabaseURL string `envconfig:"DATABASE_URL" required:"true"`
    LogLevel    string `envconfig:"LOG_LEVEL" default:"info"`
    Environment string `envconfig:"APP_ENV" default:"development"`
}

func LoadConfig() (*Config, error) {
    var cfg Config
    if err := envconfig.Process("", &cfg); err != nil {
        return nil, fmt.Errorf("config validation failed: %w", err)
    }
    return &cfg, nil
}
```

---

## Cross-Ecosystem Patterns

### Request-ID Propagation

Regardless of stack, the pattern is:
1. Check incoming `X-Request-ID` header
2. If present: use it (preserves trace across services)
3. If absent: generate UUID v4
4. Bind to logger context for all logs in this request
5. Include in response headers
6. Pass to outgoing HTTP calls to downstream services

### Metric Naming Conventions

Follow Prometheus naming conventions regardless of backend:
- Use `snake_case`
- Suffix with unit: `_seconds`, `_bytes`, `_total`
- Counter names end with `_total`
- Use base units (seconds not milliseconds, bytes not kilobytes)
- Keep label cardinality low (<10 unique values per label)

### Health Check Best Practices

- Liveness (`/health`): Check ONLY if process is alive. No dependency checks. Fast (<10ms).
- Readiness (`/health/ready`): Check critical dependencies. Timeout per check (1-3s). Return 503 if any critical check fails.
- Don't check non-critical dependencies in readiness (e.g., email service, analytics) — those cause unnecessary restarts.
- Include version in response for debugging.
- Never expose sensitive information in health responses.

### Graceful Shutdown Best Practices

- Register shutdown handlers for SIGTERM (container orchestrators) and SIGINT (local dev)
- Close connections in reverse order of initialization
- Set a hard timeout — don't wait forever
- Log the shutdown sequence for debugging
- Health endpoint should return 503 immediately on shutdown signal (before connections close)
