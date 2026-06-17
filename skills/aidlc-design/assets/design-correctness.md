# Correctness Properties Template

**Path**: `{SPECS_DIR}/{feature}/design/correctness.md`

Generated only if PBT selected in D3.

```markdown
# Correctness Properties

## Overview
**PBT Framework**: [fast-check/Hypothesis/QuickCheck/etc.]

---

## Properties

### [Property 1 Name]

**Validates**: [US-XXX, US-YYY]
**Property**: [Clear description of the invariant]

```javascript
fc.assert(fc.property(
  inputGenerator,
  (input) => {
    const result = operation(input);
    return assertProperty(result);
  }
));
```

**Generators**: [How test inputs are generated]
**Edge Cases**: [Specific edge cases to handle]

---

### [Property 2 Name]

[Same structure]

---

## Test Configuration

- **Tests per property**: [100-1000]
- **Timeout**: [Max time per test]
- **Shrinking**: Enabled — log failing input, save counterexample

**Run**: `[test command]`

**Organization**:
```
tests/properties/
├── [domain].properties.test.js
└── [domain].properties.test.js
```
```
