# EARS Notation Reference

Use these patterns for ALL acceptance criteria:

## 1. Ubiquitous (Always Active)
`The system shall [requirement]`

## 2. Event-Driven
`WHEN [trigger], THEN [response]`

## 3. State-Driven
`WHILE [state], IF [condition], THEN [response]`

## 4. Unwanted Behavior
`IF [condition], THEN [response], ELSE [alternative]`

## 5. Optional Features
`WHERE [feature/condition], WHEN [trigger], THEN [response]`

## Combining Patterns
Complex criteria can combine: "WHILE user is on checkout, WHEN user clicks 'Place Order', IF payment valid, THEN process, ELSE highlight errors"

## Best Practices
- Be specific and measurable (include timeouts, limits, formats)
- Include both happy path and error cases
- Make criteria directly testable
- One behavior per criterion
- Avoid ambiguous language ("quickly", "user-friendly")
