# Property-Based Testing Guide

Reference guide for property-based testing concepts and implementation.

## What is Property-Based Testing?

Instead of testing specific examples, test general properties that should always hold.

**Example-Based**: "2 + 2 = 4"
**Property-Based**: "For all numbers x and y, x + y = y + x (commutative)"

## Common Property Types

### 1. Idempotency
Calling operation twice produces same result as calling once.

```javascript
fc.assert(fc.property(inputGen, async (input) => {
  const result1 = await operation(input);
  const result2 = await operation(input);
  return deepEqual(result1, result2);
}));
```

### 2. Inverse Operations
Applying operation then its inverse returns original value.

```javascript
fc.assert(fc.property(inputGen, (input) => {
  const transformed = encode(input);
  const restored = decode(transformed);
  return deepEqual(input, restored);
}));
```

### 3. Invariants
Certain conditions must always hold.

```javascript
fc.assert(fc.property(inputGen, (input) => {
  const result = operation(input);
  return result.total >= 0; // Total can never be negative
}));
```

### 4. Commutativity
Order of operations doesn't matter.

```javascript
fc.assert(fc.property(fc.tuple(gen1, gen2), ([a, b]) => {
  return deepEqual(op(a, b), op(b, a));
}));
```

## Frameworks

- **JavaScript/TypeScript**: fast-check
- **Python**: Hypothesis
- **Haskell**: QuickCheck
- **Java**: jqwik
- **Scala**: ScalaCheck

## Best Practices

1. Start with simple properties
2. Use shrinking to find minimal failing cases
3. Test edge cases explicitly
4. Combine with example-based tests
5. Run in CI/CD pipeline

## When to Use PBT

**Good for**:
- Business logic with invariants
- Data transformations
- Parsers and serializers
- Mathematical operations
- State machines

**Not ideal for**:
- UI interactions
- External API calls (use mocks)
- Time-dependent operations
- Random behavior
