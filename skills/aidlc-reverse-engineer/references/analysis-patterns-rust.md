# Analysis Patterns: Rust

**Config files**: `Cargo.toml`, `Cargo.lock`, `rust-toolchain.toml`, `.cargo/config.toml`
**Entry points**: `src/main.rs`, `src/lib.rs`, `src/bin/*.rs`
**Frameworks**: Actix Web (`#[get]`, `#[post]`, `HttpServer`), Axum (`Router::new().route`), Rocket (`#[get]`, `#[post]`), Warp (`warp::path`), Poem, Tide
**ORM/DB**: Diesel (`table!`, `#[derive(Queryable)]`), SeaORM (`#[derive(DeriveEntityModel)]`), SQLx (`sqlx::query!`), SurrealDB client
**Route detection**: Actix/Rocket attribute macros, Axum `Router` builder, Warp filter chains
**Business logic signals**: `impl` blocks with domain methods, `validate` functions returning `Result`, enum-based state machines with `match`, trait implementations for domain behavior
**Test patterns**: `#[cfg(test)] mod tests`, `#[test]`, `assert!`/`assert_eq!`, `tests/` integration directory, `proptest`/`quickcheck` for PBT

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
