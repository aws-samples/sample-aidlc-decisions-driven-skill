# Analysis Patterns: Go

**Config files**: `go.mod`, `go.sum`, `Makefile`, `Dockerfile`
**Entry points**: `cmd/*/main.go`, `main.go`
**Frameworks**: Standard library `net/http`, Gin (`gin.Engine`), Echo (`echo.New`), Fiber (`fiber.New`), Chi (`chi.NewRouter`), gorilla/mux, Connect (gRPC-compatible)
**ORM/DB**: GORM (`gorm.Model`), sqlx, pgx, ent (`ent.Schema`), Bun, `migrations/`, goose/migrate
**Route detection**: `http.HandleFunc`, `r.GET/POST`, handler function signatures, `chi.Route`
**Business logic signals**: Domain packages, `validate` functions, `calculate` functions, `type State int` with const iota
**Test patterns**: `*_test.go`, `testing.T`, table-driven tests, `testify`

## Business Rule Extraction Heuristics

| Signal | What It Indicates |
|---|---|
| `if/switch` on status/state fields | State machine or workflow |
| Validation functions with error returns | Business validation rules |
| Functions named `calculate*`, `compute*`, `derive*` | Business calculations |
| Role/permission checks before operations | Authorization rules |
| Assertions or guard clauses at function start | Invariants |
| Cron/scheduler configurations | Scheduled business processes |
| Event handlers / message consumers | Event-driven business logic |
| Constants with business meaning (rates, limits, thresholds) | Business parameters |
| Enum types with domain names | Domain concepts / state definitions |
