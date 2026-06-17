# Units of Work — Output Template

Generate `{SPECS_DIR}/{feature}/units.md` with this structure.

```markdown
# Units of Work

## Summary
<!-- 10-line max. Downstream phases read ONLY this section. -->
- **Units**: [X] units — [list names]
- **Strategy**: [Domain-Driven/Layer-Based/User Journey-Based/Hybrid]
- **Architecture**: [Pattern from D2]
- **Story Distribution**: [Unit1: X stories, Unit2: Y stories]
- **Key Dependencies**: [Unit A → Unit B (type)]
- **Development Sequence**: [Phase 1: Unit X, Phase 2: Unit Y]

## Overview
Feature decomposed into [X] units for [parallel development/phased delivery/clear separation].

**Strategy**: [Domain-Driven/Layer-Based/User Journey-Based/Hybrid]
**Rationale**: [Why this approach]

---

## Unit 1: [Name]

**Purpose**: [What this unit does — 1-2 sentences]
**Priority**: [High/Medium/Low]
**Complexity**: [Low/Medium/High]
**Stories**: [X] stories — [US-001, US-002, US-003]

### Commands
| Command | Description | Actor |
|---------|-------------|-------|
| [CreateX] | [What it does] | [User/System] |
| [UpdateX] | [What it does] | [User/System] |

### Domain Model
**Aggregates**: [AggregateName] (root: [EntityName])
**Entities**: [Entity1, Entity2]
**Value Objects**: [VO1, VO2]

### Domain Events
**Publishes**: [EventName] — [When triggered]
**Subscribes**: [EventName] from [Unit] — [What happens]

### Dependencies
| Depends On | Type | Description |
|------------|------|-------------|
| [Unit Name] | [Data/API/Event] | [What is needed] |

---

## Unit 2: [Name]

[Same structure as Unit 1]

---

## Context Map

| Upstream | Downstream | Pattern |
|----------|------------|---------|
| Unit A | Unit B | Customer/Supplier |
| Unit A | Unit C | Publisher/Subscriber |

**Patterns**: Customer/Supplier, Conformist, Publisher/Subscriber, Anti-Corruption Layer, Shared Kernel

---

## Development Sequence

### Phase 1: Foundation
- [ ] Unit 1: [Name] — [Rationale]

### Phase 2: Core
- [ ] Unit 2: [Name] — [Rationale]

### Phase 3: Supporting
- [ ] Unit 3: [Name] — [Rationale]
```
