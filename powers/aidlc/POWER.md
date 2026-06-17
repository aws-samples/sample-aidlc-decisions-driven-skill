---
name: "aidlc"
displayName: "AI-DLC: Decision-Driven Development"
description: "AI-Driven Development Life Cycle with decision gates. Orchestrates specification workflow from context assessment through implementation with structured decision points at each phase."
keywords: ["aidlc", "specification", "workflow", "decision-gate", "requirements", "design", "decomposition"]
author: "AI-DLC Maintainers"
---

# AI-DLC: Decision-Driven Development

## Overview

AI-DLC (AI-Driven Development Life Cycle) is a structured specification workflow that guides you from initial context assessment through implementation. Each phase produces artifacts with explicit decision gates — you make the choices, the AI executes.

The workflow adapts to project complexity:
- **Simple projects**: Context → Requirements → Design → Tasks → Implement
- **Complex projects**: Context → Requirements → Decomposition → Foundation → per-unit Design → Tasks → Implement
- **Quick mode**: Single-pass spec for small brownfield features

## How It Works

AI-DLC is implemented as a set of **skills** that get installed into your workspace. Once installed, you activate the orchestrator skill (`aidlc`) which manages the workflow — reading project state, dispatching to phase skills, and handling resume/rollback.

### Commands

| Command | What It Does |
|---|---|
| `start` | Begin a new feature specification |
| `resume` | Pick up where you left off |
| `status` | Show current workflow progress |
| `next` | Continue to the next phase |
| `help` | Explain current position and available options |
| `rollback` | Go back to a previous phase |
| `repair` | Rebuild manifest from disk artifacts |
| `quick` | Single-pass mode for simple features |
| `doctor` | Verify installation health and cross-references |
| `prototype` | Build a throwaway spike to validate requirements |
| `review` | Run solutions review or code review |
| `reverse-engineer` | Deep codebase analysis (13 report documents) |
| Phase names | Jump to any phase: `context`, `requirements`, `design`, `tasks`, etc. |

### Phases

1. **Context** — Scan workspace, detect stack, assess project landscape
2. **Requirements** — User stories with EARS acceptance criteria + decision gate
3. **Decomposition** — Break into units of work (complex projects) + decision gate
4. **Foundation** — Shared conventions for multi-unit projects + decision gate
5. **Design** — Technology decisions and architecture + decision gate
6. **Tasks** — Sequenced implementation tasks with execution waves + decision gate
7. **Implement** — Code generation from task specs

Each phase (except Context) has a **decision gate** — a set of questions you answer to guide the AI's output. You can fill answers manually or say "use recommendations" to auto-fill.

## Installation

### Prerequisites

- Kiro IDE
- File system access

### Install Skills

Copy the skills from this repository into your project:

```bash
cp -r skills/aidlc* /path/to/your/project/.kiro/skills/
```

### Verify Installation

After copying, your project should have:
```
.kiro/skills/
├── aidlc/                    ← orchestrator + shared base
│   ├── shared/               ← environment detection, manifest ops, behavioral rules
│   └── actions/
├── aidlc-context/
├── aidlc-requirements/
├── aidlc-decomposition/
├── aidlc-design/
├── aidlc-foundation/
├── aidlc-tasks/
├── aidlc-implement/
├── aidlc-prototype/
├── aidlc-reverse-engineer/
├── aidlc-code-review/
└── aidlc-solutions-review/
```

## Usage

### Starting a New Feature

1. Activate the `aidlc` skill (say "start" or mention AI-DLC)
2. Describe your feature
3. The orchestrator scans your workspace and begins the context phase
4. Follow the prompts — each phase presents results and waits for your approval

### Resuming Work

Say "resume" or "status" — the orchestrator reads the manifest at `.aidlc/workflow/{feature}/aidlc-manifest.yaml` and picks up where you left off.

### Reverse Engineering an Existing Codebase

Say "reverse-engineer" to run deep codebase analysis. Produces 13 comprehensive documents covering architecture, data model, API surface, business rules, features, integrations, conventions, infrastructure, security, configuration, and technical debt.

## Output Structure

```
.aidlc/
├── specs/{feature}/           ← specification artifacts
│   ├── context.md
│   ├── requirements.md
│   ├── units.md
│   ├── foundation.md
│   ├── design/
│   └── tasks.md
├── workflow/{feature}/        ← workflow state
│   ├── aidlc-manifest.yaml
│   ├── audit.md
│   └── decisions-*.md
└── reverse-engineer/          ← codebase analysis (if run)
    ├── README.md
    ├── overview.md
    ├── modules.md
    └── ... (13 files total)
```

## Platform

This power is designed for **Kiro**. Skills in `.kiro/skills/`, steering files in `.kiro/steering/`.

> For other platforms (Claude Code, Cursor, Windsurf), see the [README](../../README.md) for installation instructions.

## Troubleshooting

### Skills Not Activating

**Problem**: Saying "start" or "aidlc" doesn't trigger the workflow.

**Solution**:
1. Verify skills are installed: check `.kiro/skills/aidlc/SKILL.md` exists
2. Restart Kiro to reload skills
3. Try explicitly: "activate the aidlc skill"

### Manifest Corruption

**Problem**: Workflow state seems wrong or inconsistent.

**Solution**: Say "repair" — the orchestrator rebuilds the manifest from disk artifacts.

### Context Lost Mid-Session

**Problem**: After a long session, the AI loses track of the workflow.

**Solution**: Say "resume" — the orchestrator re-reads the manifest and presents current state.

### Wrong File Paths in Incremental Mode

**Problem**: Unit artifacts written to wrong directory.

**Solution**: Unit artifacts should always be in `.aidlc/specs/{feature}/units/{unit}/`. If they're in the wrong place, say "repair" to rebuild state.
