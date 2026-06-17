# Decomposition Strategies Reference

## Domain-Driven (Recommended)
Group by business domain or bounded context.

**Pros**: Aligns with business, clear ownership, independent evolution
**Cons**: May have data duplication, requires domain expertise
**Example**: User Management, Product Catalog, Order Processing, Payment

**How to identify domains**:
1. Look for clusters of related user stories
2. Identify nouns that appear together (Order + OrderItem + Shipping = Order domain)
3. Find natural boundaries where data ownership changes
4. Ask: "If this changed, what else would need to change?"

## Layer-Based
Group by technical layer.

**Pros**: Clear technical separation, reusable components
**Cons**: Changes often span multiple units, tight coupling
**Example**: API Layer, Business Logic, Data Access, Infrastructure

## User Journey-Based
Group by user workflow or end-to-end experience.

**Pros**: Delivers complete features, user-centric, easy to demo
**Cons**: May duplicate technical components
**Example**: Onboarding Flow, Core Experience, Checkout Process

## Hybrid
Combine strategies — e.g., domain-driven for backend, user-journey for frontend.

## Sizing Guidance

**Too small** (merge): 1-2 stories, no independent value.
**Right size**: 3-8 stories, clear boundary, meaningful deliverable.
**Too large** (split): 15+ stories, multiple domains mixed.

## DDD Concepts

**Commands**: Actions that change state — CreateUser, UpdateOrder, ProcessPayment.

**Domain Model**:
- **Aggregates**: Cluster of entities as a unit. Root entity. Example: Order (root) + OrderItems + ShippingAddress.
- **Entities**: Objects with identity (User, Product, Order).
- **Value Objects**: Objects without identity (Money, Address, DateRange).

**Domain Events**: Past tense. Published by one unit, consumed by others — UserCreated, OrderPlaced, PaymentProcessed.

**Context Map Patterns**:

| Pattern | When to Use |
|---|---|
| Customer/Supplier | Clear provider/consumer |
| Conformist | Can't influence upstream |
| Publisher/Subscriber | React to each other's changes |
| Anti-Corruption Layer | Protect from external complexity |
| Shared Kernel | Small, stable shared concepts |

## Common Pitfalls

1. **Over-decomposition**: Too many tiny units needing constant coordination
2. **Circular dependencies**: Unit A depends on B, B depends on A — merge or introduce events
3. **Shared database**: Multiple units writing to same tables — define clear data ownership
4. **Anemic units**: Just CRUD wrappers with no real business logic — consider merging
5. **Big ball of mud**: One unit does everything — look for natural seams to split
