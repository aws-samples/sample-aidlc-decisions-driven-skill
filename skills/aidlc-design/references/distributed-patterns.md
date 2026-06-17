# Distributed System Patterns Guide

Reference guide for distributed system design patterns and consistency models.

## When to Use Distributed Patterns

Use these patterns when building:
- Microservices architectures
- Event-driven systems
- High-scale distributed applications
- Systems with multiple databases
- Long-running business processes
- Systems requiring high availability

## CQRS (Command Query Responsibility Segregation)

Separate read and write operations into different models.

**Pattern**:
- **Commands**: Change state (write operations)
- **Queries**: Read state (read operations)
- Separate models optimized for each

**When to use**:
- Different read/write performance requirements
- Complex business logic on writes
- High read-to-write ratio
- Need to scale reads and writes independently

**Pros**: Optimized models, independent scaling, clear separation
**Cons**: Increased complexity, eventual consistency, data duplication

**Example**:
```
Write Side:
User → Command → Command Handler → Write DB → Event

Read Side:
Event → Projection → Read DB → Query → User
```

## Event Sourcing

Store state changes as sequence of events instead of current state.

**Pattern**:
- Store all events (UserCreated, OrderPlaced, PaymentProcessed)
- Rebuild current state by replaying events
- Events are immutable and append-only

**When to use**:
- Need complete audit trail
- Time-travel debugging required
- Complex domain with state transitions
- Event-driven architecture

**Pros**: Complete history, audit trail, time-travel, event replay
**Cons**: Complexity, eventual consistency, event schema evolution

**Example**:
```
Events: [UserCreated, EmailUpdated, UserDeactivated]
Current State = Replay all events
```

## Saga Pattern

Manage distributed transactions across multiple services.

### Choreography (Event-Based)
Services react to events, no central coordinator.

**Pattern**:
```
Service A → Event → Service B → Event → Service C
                ↓ Compensation Event (if failure)
```

**When to use**:
- Simple workflows
- Loose coupling preferred
- Few participants (2-4 services)

**Pros**: Loose coupling, no single point of failure, scalable
**Cons**: Hard to understand flow, difficult to debug, no central monitoring

### Orchestration (Coordinator-Based)
Central orchestrator manages the workflow.

**Pattern**:
```
Orchestrator → Service A → Success
            → Service B → Success
            → Service C → Failure → Compensate B → Compensate A
```

**When to use**:
- Complex workflows
- Many participants (5+ services)
- Need centralized monitoring
- Clear workflow visibility needed

**Pros**: Clear workflow, easier to debug, centralized monitoring, easier to add steps
**Cons**: Orchestrator is single point of failure, tighter coupling

### Compensation Transactions
Undo operations when saga fails.

**Example**:
- Order placed → Payment processed → Inventory reserved
- If shipping fails → Release inventory → Refund payment → Cancel order

## Distributed Transactions

### Two-Phase Commit (2PC)
Coordinator ensures all participants commit or rollback.

**Phases**:
1. **Prepare**: Ask all participants if ready to commit
2. **Commit/Rollback**: If all ready, commit; if any fail, rollback

**When to use**: Strong consistency required, can tolerate blocking
**Pros**: Strong consistency, ACID guarantees
**Cons**: Blocking, coordinator is single point of failure, slow

### Three-Phase Commit (3PC)
Adds pre-commit phase to reduce blocking.

**When to use**: Need non-blocking, strong consistency
**Pros**: Non-blocking, handles coordinator failure
**Cons**: More complex, still slow, network partition issues

### Avoid When Possible
Distributed transactions are complex and slow. Prefer:
- Eventual consistency with sagas
- Idempotent operations
- Compensating transactions

## Consistency Models

### Strong Consistency
All nodes see the same data at the same time.

**When to use**: Financial transactions, inventory management, critical data
**Pros**: Simple to reason about, no conflicts
**Cons**: Lower availability, higher latency, harder to scale

**Implementation**: Synchronous replication, distributed locks, 2PC

### Eventual Consistency
Nodes may temporarily have different data, but will converge.

**When to use**: Social media, content delivery, analytics, non-critical data
**Pros**: High availability, low latency, scales well
**Cons**: Temporary inconsistencies, conflict resolution needed

**Implementation**: Asynchronous replication, event-driven updates, CRDTs

### Causal Consistency
Operations that are causally related are seen in order.

**When to use**: Collaborative editing, chat systems, social feeds
**Pros**: Balance between strong and eventual, preserves causality
**Cons**: More complex than eventual, not as strong as strong consistency

## Locking Mechanisms

### Optimistic Locking
Assume conflicts are rare, detect at commit time.

**Pattern**:
1. Read data with version number
2. Make changes locally
3. Commit with version check
4. If version changed, conflict detected → retry

**When to use**: Low contention, read-heavy workloads, better performance

**Implementation**: Version field, ETag, timestamp

**Example**:
```sql
UPDATE users SET name = 'New', version = version + 1
WHERE id = 123 AND version = 5
-- If 0 rows updated, conflict detected
```

### Pessimistic Locking
Lock data before modifying, prevent conflicts.

**Pattern**:
1. Acquire lock on data
2. Make changes
3. Commit and release lock

**When to use**: High contention, write-heavy workloads, conflicts are expensive

**Implementation**: Database locks (SELECT FOR UPDATE), distributed locks (Redis, Zookeeper)

**Example**:
```sql
BEGIN TRANSACTION;
SELECT * FROM users WHERE id = 123 FOR UPDATE;
UPDATE users SET name = 'New' WHERE id = 123;
COMMIT;
```

### Distributed Locks
Coordinate access across multiple services.

**Tools**: Redis (Redlock), Zookeeper, etcd, DynamoDB

**When to use**: Multiple services need to coordinate, prevent duplicate processing

## Outbox Pattern

Ensure database changes and event publishing are atomic.

**Pattern**:
1. Write to database AND outbox table in same transaction
2. Background process reads outbox and publishes events
3. Mark events as published

**When to use**: Need atomic database + event publishing, microservices with events

**Example**:
```sql
BEGIN TRANSACTION;
INSERT INTO orders (id, user_id, total) VALUES (...);
INSERT INTO outbox (event_type, payload) VALUES ('OrderCreated', '...');
COMMIT;
```

## Idempotency

Operations can be applied multiple times with same result.

**When to use**: Distributed systems, message queues, retries, at-least-once delivery

**Implementation**:
- Idempotency keys (UUID per request)
- Store processed keys
- Check before processing

**Example**:
```
POST /api/orders
Headers: Idempotency-Key: uuid-123

If uuid-123 already processed → return cached result
Else → process and store result with uuid-123
```

## Circuit Breaker

Prevent cascading failures by stopping calls to failing services.

**States**:
- **Closed**: Normal operation, calls go through
- **Open**: Service failing, reject calls immediately
- **Half-Open**: Test if service recovered

**When to use**: Microservices, external API calls, prevent cascading failures

## Bulkhead Pattern

Isolate resources to prevent total system failure.

**Pattern**: Separate thread pools, connection pools, or instances per service/feature

**When to use**: Prevent one failing component from taking down entire system

## Retry Strategies

### Exponential Backoff
Increase wait time between retries exponentially.

**Pattern**: Wait 1s, 2s, 4s, 8s, 16s...

### Jitter
Add randomness to retry timing to prevent thundering herd.

**Pattern**: Wait (base * 2^attempt) + random(0, jitter)

## Data Consistency Strategies

### Read-Your-Writes
User sees their own writes immediately.

### Monotonic Reads
User never sees older data after seeing newer data.

### Monotonic Writes
User's writes are applied in order.

## Conflict Resolution

### Last-Write-Wins (LWW)
Most recent write wins based on timestamp.

### Version Vectors
Track causality to detect conflicts.

### CRDTs (Conflict-Free Replicated Data Types)
Data structures that automatically resolve conflicts.

**When to use**: Collaborative editing, distributed counters, sets

## Best Practices

1. **Design for failure** — assume services will fail
2. **Use idempotency** — make operations safe to retry
3. **Implement timeouts** — don't wait forever
4. **Use circuit breakers** — fail fast
5. **Choose consistency model** — strong vs eventual
6. **Plan for compensation** — how to undo operations
7. **Monitor distributed traces** — understand request flow
8. **Test failure scenarios** — chaos engineering
9. **Document patterns used** — make decisions explicit
10. **Keep it simple** — only use patterns when needed
