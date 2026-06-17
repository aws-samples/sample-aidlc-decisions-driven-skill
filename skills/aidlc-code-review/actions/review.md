# Action: review-code

## Step 1: Gather Context

Read available context:
- **Design documents** (if available): architecture, components, data model, API contracts, conventions
- **Foundation conventions** (if available): coding standards, naming, error handling, shared types
- **Tasks** (if available): what was supposed to be implemented, completeness check
- **Tech stack** from `{STEERING_DIR}/tech.md` (if available): expected frameworks, libraries, patterns

If no design docs available, review against general best practices only.

## Step 2: Read Source Code

Based on determined scope:
- **Full review**: read source files following design/implementation.md directory structure
- **Scoped review**: read all files in specified paths
- **Diff review**: read only changed files
- **Task review**: read files listed in task's implementation details

For large codebases, prioritize: entry points → business logic → data access → auth → error handling → tests → config.

## Step 3: Review Categories

Check each category. Skip categories that don't apply.

**Design Compliance** (if design docs available):
- Component structure matches design/components.md
- Data models match design/data-model.md (fields, types, relationships, indexes)
- API endpoints match design/api-spec.md (paths, methods, schemas, error codes)
- Directory structure matches design/implementation.md
- Technology choices consistent with D3 (no unauthorized libraries)

**Correctness**: Logic errors, edge cases, async correctness, state management, data validation

**Security**: SQL injection, XSS, auth bypass, authorization gaps, secret handling, input validation, CORS, rate limiting, dependency vulnerabilities

**Error Handling**: Async error handling, contextual logging, no leaked internals, agreed format, graceful degradation, retry with backoff

**Performance**: N+1 queries, missing indexes, unbounded queries, memory leaks, unnecessary re-renders, large uncompressed payloads

**Test Quality**: Coverage of critical paths, isolation, assertion quality, edge cases, mocking, naming, missing tests

**Code Quality**: Naming clarity, function size, duplication, dead code, consistent patterns, documentation, type safety

**Convention Compliance** (if foundation.md available): Naming, error format, logging format, file organization, shared types usage

**Accessibility** (if frontend framework in stack): Semantic HTML, ARIA, keyboard nav, color contrast, focus management, form labels, alt text, skip nav

## Step 4: Classify Findings

- 🔴 **Critical**: Bug, security vulnerability, data loss risk, production issues. Must fix.
- 🟡 **Major**: Significant quality issue, missing error handling, test gaps, performance. Should fix.
- 🟢 **Minor**: Style, naming, minor optimization, documentation gap. Nice to fix.
- 💡 **Suggestion**: Better approach exists. Optional.

Finding IDs: `CODE-CR-N` (critical), `CODE-MJ-N` (major), `CODE-MN-N` (minor), `CODE-SG-N` (suggestion).

## Step 5: Generate Report

**Write** `{WORKFLOW_DIR}/{feature}/code-review.md` with:
- Review Summary (date, scope, file count, finding counts, compliance status, coverage assessment)
- Findings grouped by severity (each with: file, lines, category, description, code snippet, fix, impact)
- Design Compliance Summary table (per design artifact)
- Test Coverage Summary table (per area)
- Missing Tests list
- Recommendations (must fix / should fix / consider)

## Step 6: Present Results

```
📍 Code Review Complete

- **Files Reviewed**: {count}
- **Critical**: {X} issues
- **Major**: {Y} issues
- **Minor**: {Z} issues
- **Suggestions**: {W}
- **Design Compliance**: {status}
- **Test Coverage**: {status}

Report at `{WORKFLOW_DIR}/{feature}/code-review.md`.

---
🔲 **Your turn**:
- 🔧 "fix CODE-CR-1" — apply the suggested fix
- 🔧 "fix all critical" — apply all critical fixes
- 🔧 "fix all" — apply all suggested fixes
- ✅ "done" — acknowledge review
- 🔍 "re-review" — run again after fixes
```

**STOP and wait.**

On "done": If manifest exists, add `artifacts.code-review` entry with status/timestamp/files.
