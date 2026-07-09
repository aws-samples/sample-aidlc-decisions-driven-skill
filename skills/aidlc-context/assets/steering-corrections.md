# Steering: Corrections — Output Template

Generate `{BLUEPRINTS_DIR}/corrections.md` when the first correction is recorded (canonical, platform-agnostic — no front-matter).

**All platforms**: This file is loaded every session because the platform shim references it (Kiro `#[[file:.aidlc/blueprints/corrections.md]]`, Claude `@../.aidlc/blueprints/corrections.md`).

Do NOT create this file during context assessment. It is created on-demand when the user confirms a correction should be remembered (see Edit Action Pattern in shared/base.md).

## Format

```markdown
# Project Corrections

Rules learned from human feedback during AI-DLC workflows. These apply to ALL future workflows in this project.

## Coding Style

<!-- Append rules about code patterns, naming, structure -->

## Architecture

<!-- Append rules about design decisions, patterns, technology choices -->

## Process

<!-- Append rules about workflow preferences, testing approach, documentation style -->

## Conventions

<!-- Append rules about project-specific conventions not covered above -->
```

## Append Format

When adding a new correction, append under the most relevant section heading:

```markdown
- **[ALWAYS/NEVER/PREFER]** [concise rule] — _{source: phase where learned, ISO date}_
```

Examples:
- **ALWAYS** use Result<T,E> for error handling in service layer — _source: design, 2026-04-15_
- **NEVER** use default exports in TypeScript files — _source: implement, 2026-04-16_
- **PREFER** composition over inheritance for data access patterns — _source: design, 2026-04-15_
- **ALWAYS** include request correlation ID in all log entries — _source: implement, 2026-04-17_

## Rules for Appending

- One rule per line (dash-prefixed)
- Use ALWAYS/NEVER/PREFER prefix for clarity
- Include source phase and date for traceability
- Do NOT duplicate existing rules — if a similar rule exists, strengthen or refine it
- Keep rules concise (one sentence max)
- If a rule contradicts an existing one, replace the old rule and note the change
