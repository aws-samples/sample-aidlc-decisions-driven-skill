# Action: resolve-conflict

For merge conflicts during parallel or incremental implementation.

## Resolution Strategies

| Strategy | When to Use | Description |
|---|---|---|
| **Merge Both** | Changes are complementary | Combine functionality from both sides |
| **Choose One** | Mutually exclusive changes | Evaluate alignment with design, consider file ownership |
| **Refactor** | Conflict indicates design issue | Extract shared functionality, propose interface changes |
| **Escalate** | Architectural misalignment | Flag for review — reveals a gap in the design |

## Resolution Process

1. **Understand**: Read conflicting files, identify conflict markers, determine which phases/units involved
2. **Gather Context**: Read design docs for involved phases/units, check related files
3. **Analyze Impact**: Identify downstream dependencies, assess impact on other phases/units
4. **Propose Resolution**: Explain conflict, present options with pros/cons, recommend approach, show resolved code
5. **Verify**: Ensure code compiles/runs, both phases' requirements met, no new conflicts, run tests

## When to Escalate

Present to user for decision when:
- Fundamental architectural misalignment between phases
- Conflicting design interpretations not resolvable from specs
- Resolution would require design document changes
- Same conflict pattern appearing across multiple files

## Output Format

```
⚠️ Conflict Detected

**Files**: [list]
**Phases/Units**: [involved]
**Type**: [overlapping routes / conflicting config / etc.]
**Root Cause**: [why]
**Strategy**: [chosen]
**Resolution**: [what was done]
**Verification**: [tests run, results]
```
