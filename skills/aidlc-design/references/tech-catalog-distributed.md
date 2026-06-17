# Technology Catalog — Distributed Systems

> Load ONLY if architecture = microservices or distributed system.

## Distributed System Patterns

- **Consistency Model**: Strong consistency, Eventual consistency, Causal consistency
- **Distributed Transactions**: Saga (Choreography), Saga (Orchestration), 2PC, Avoid (use idempotency)
- **CQRS**: Yes (separate read/write models), No (unified model)
- **Event Sourcing**: Yes (store events), No (store current state)
- **Locking Strategy**: Optimistic locking, Pessimistic locking, Distributed locks, None
- **Outbox Pattern**: Yes (atomic events), No (direct publishing)
- **Idempotency**: Required (with idempotency keys), Optional, Not needed
- **Circuit Breaker**: Enabled (for external calls), Disabled
- **Retry Strategy**: Exponential backoff with jitter, Fixed delay, No retries
