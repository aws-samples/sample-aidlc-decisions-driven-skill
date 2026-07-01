# How This Differs from Official AIDLC Workflows

This project is an **opinionated, community implementation** of the [AI-DLC methodology](https://prod.d13rzhkk8cj2z0.amplifyapp.com/). The official AIDLC workflow definitions are maintained at [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows).

Both share the same core principles. They differ in how those principles are delivered.

## Comparison

| Aspect | Official AIDLC Workflows | This Implementation |
|---|---|---|
| Format | Platform-integrated workflow definitions | Plain markdown skill files (copy to any project) |
| Portability | Kiro-native | Kiro + Claude Code (same files, no adaptation) |
| Dependencies | Platform workflow engine | None — works with any AI assistant that reads files |
| Customization | Configuration-based | Fork and edit markdown directly |
| Approach | Standard, validated workflows | Opinionated — prioritizes developer ergonomics and context efficiency |
| Versioning | Managed by AWS | Community-maintained, semver |

## Shared Principles

Both implement:
- Decision gates at each phase (D1–D5) with conflict validation
- Traceability across the full chain (requirements → design → tasks → build)
- Manifest-based state tracking for pause/resume/rollback
- Scope-adaptive workflow (new/feature/bugfix/refactor)
- Human-in-the-loop approval at every checkpoint

## Why This Implementation Exists

This project offers an alternative path for teams that want:

- **Zero dependencies** — no platform engine, no build step, no runtime. Just markdown files.
- **Full transparency** — every instruction the AI follows is readable and editable in your project.
- **Multi-platform** — same skill files work on Kiro IDE, Kiro CLI, and Claude Code without adaptation.
- **Fork-friendly** — customize any phase by editing markdown. No plugin API to learn.
- **Context-efficient** — layered instruction loading designed to minimize token consumption in long sessions.

## When to Use Which

| Use Case | Recommended |
|---|---|
| Standard Kiro workflow with official support | [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) |
| Claude Code or multi-platform teams | This implementation |
| Heavily customized workflow per team | This implementation (fork and edit) |
| Minimal setup, maximum portability | This implementation |
| Enterprise with AWS support requirements | Official AIDLC Workflows |
