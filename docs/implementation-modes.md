# Implementation Modes

## Execution Modes

The implementation skill offers three modes:

### Standard Mode

Tasks executed one at a time. You review and approve after each task. Best for learning the codebase or when you want tight control.

### Parallel Mode

Tasks grouped into dependency waves. Each wave dispatches one sub-agent per phase. Phases within a wave run simultaneously with isolated file ownership. You review after each wave.

- Requires Kiro Autopilot mode or Claude Code

### Autonomous Mode

All waves executed without stopping. Failed tasks retry up to 5 times, then get skipped. Tasks depending on failed tasks are also skipped. You get a single summary at the end.

- Same platform requirements as parallel mode
- Best when you trust the spec fully

## Incremental vs. Comprehensive

After decomposition, you choose a delivery mode:

### Comprehensive

A single design covering all units. Best for tightly coupled units or small projects.

Workflow: `design → tasks → implement` (all at once).

### Incremental

Design, task, and implement one unit at a time. Recommended for 2+ units.

- The decomposition skill proposes a foundation unit (first in sequence) when shared scaffolding is needed
- Workflow: `(select unit → design → tasks → implement) × N`

In incremental mode, each unit gets its own scoped directory (`{SPECS_DIR}/{feature}/units/{unit}/`) with its own design docs and tasks.

### Mode Selection Recommendation

The skill recommends a mode based on context:

| Condition | Recommended Mode |
|---|---|
| Solo dev OR ≤10 tasks | Standard |
| 2+ waves AND Kiro/Claude Code AND want review checkpoints | Parallel |
| 2+ waves AND Kiro/Claude Code AND trust the spec | Autonomous |
