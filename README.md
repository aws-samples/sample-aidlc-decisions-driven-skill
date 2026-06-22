# AI-DLC — AI Development Lifecycle Skills

A structured, decision-driven workflow for AI-assisted software development. AI-DLC guides projects from initial context assessment through requirements, design, task planning, implementation, build verification, and deployment — with built-in decision gates at every phase.

## Why AI-DLC

AI coding assistants are powerful but undirected. Without structure, they produce inconsistent architectures, skip edge cases, and make technology choices that don't align with your project. AI-DLC introduces a lightweight lifecycle that keeps the AI focused and the human in control.

- **Decision gates** at each phase surface the right questions and validate answers before moving forward
- **Manifest-based state tracking** lets you pause, resume, and roll back across sessions
- **Incremental delivery** for complex projects — decompose into units, design and implement one at a time
- **Parallel implementation** via sub-agents with file ownership isolation
- **Multi-platform** — works on Kiro (IDE and CLI) and Claude Code

## Quick Start

### Installation

Clone the repo and copy the skills into your project:

```bash
git clone <repo-url> aidlc-skills
cd aidlc-skills
```

**Kiro (IDE or CLI):**
```bash
cp -r skills/aidlc* /path/to/your/project/.kiro/skills/
```

**Claude Code:**
```bash
cp -r skills/aidlc* /path/to/your/project/.claude/skills/
```

#### Optional: Install as Kiro Power

1. Open the **Powers** panel (Command Palette → "Powers: Open Panel")
2. Click **"Add Custom Power"** → **"Import power from a folder"**
3. Select the `powers/aidlc` folder from this repo

### Your First Feature

Just tell the AI what you want to build:

```
/aidlc build a todo app with user authentication, task management, and notifications
```

Or point it to an existing requirements document:

```
/aidlc build the application described in docs/requirements.md
```

Try one of the [example requirements](examples/requirements/) included in this repo:

```
/aidlc build the application described in examples/requirements/requirements-en-art-toys.md
```

### Available Commands

| Command | What It Does |
|---|---|
| `start` | Begin a new feature specification |
| `resume` | Pick up where you left off |
| `status` | Show current workflow progress |
| `next` | Continue to the next phase |
| `rollback` | Go back to a previous phase |
| `repair` | Rebuild manifest from disk artifacts |
| `quick` | Single-pass spec for simple brownfield features |
| `doctor` | Verify installation health |
| `scope [name]` | Change workflow scope (new/feature/bugfix/refactor) |
| `prototype` | Build a throwaway spike to validate requirements |
| `review` | Run solutions review or code review |
| `reverse-engineer` | Deep codebase analysis (13 reports) |
| Phase names | Jump directly: `context`, `requirements`, `design`, `tasks`, `implement`, `build`, `deploy` |

> **Note**: `units` and `decomposition` refer to the same phase — both work interchangeably.

## Workflow Overview

AI-DLC organizes the development lifecycle into three phases:

| Phase | Covers | Skills |
|---|---|---|
| **Inception** | Context assessment, requirements, decomposition into units | aidlc-context, aidlc-requirements, aidlc-decomposition |
| **Construction** | Technology decisions, design, task planning, implementation | aidlc-design, aidlc-tasks, aidlc-implement |
| **Operation** | Build verification, CI/CD pipeline generation, deployment | aidlc-build, aidlc-deploy |

### Scope-Adaptive Workflow

The workflow adapts to your task. Scope is auto-detected from your request and workspace, or you can set it manually with `scope [name]`.

| Scope | Phases | Best For |
|---|---|---|
| `new` | All phases | New projects, rewrites |
| `feature` | All phases | Adding capability to existing code |
| `bugfix` | Context → Requirements → Design → Tasks → Implement → Build | Fixing specific bugs (skips decomposition, deploy) |
| `refactor` | Context → Design → Tasks → Implement → Build | Restructuring code (skips requirements, decomposition, deploy) |

```mermaid
flowchart TD
    subgraph Inception
        A[Context] --> B[Requirements]
        B --> C{Complex?}
        C -->|Complex| E[Decomposition]
    end

    subgraph Construction
        C -->|Simple| D[Design]
        D --> T[Tasks]
        T --> I[Implement]
        E --> Units
        subgraph Units ["For Each Unit"]
            direction TB
            UD[Design] --> UT[Tasks] --> UI[Implement]
        end
    end

    subgraph Operation
        BT[Build and Test]
        DEP[Deploy]
        BT --> DEP
    end

    Units --> BT
    I --> BT
    B -.->|optional| P[Prototype]
    P -.->|refine| B
```

**Simple projects** go straight from requirements to design → implement → build → deploy.

**Complex projects** (5+ stories, 2+ domains) decompose into units, then design and implement each independently before building and deploying.

## Documentation

| Document | Description |
|---|---|
| [Skills Reference](docs/skills-reference.md) | All skills — what they do, what they read/write |
| [Decision Gates](docs/decision-gates.md) | D1–D5 details, how they work, conflict validation |
| [Artifacts](docs/artifacts.md) | All generated files, paths, and platform variables |
| [Implementation Modes](docs/implementation-modes.md) | Standard, parallel, autonomous; incremental vs comprehensive |
| [Manifest Schema](docs/manifest-schema.md) | v2.2 manifest format with full YAML example |
| [Skill Anatomy](docs/skill-anatomy.md) | How skills are structured, extending AI-DLC |
| [Context Recovery](docs/context-recovery.md) | How resume and session recovery works |

## Examples

| Example | Description |
|---|---|
| [Todo App](examples/todo-app/) | Complete workflow output — all artifacts from a simple project |
| [Example Requirements](examples/requirements/) | Business requirements in English and Thai for testing |

## Resources

| Resource | Description |
|---|---|
| [AI-DLC Whitepaper](https://prod.d13rzhkk8cj2z0.amplifyapp.com/) | Methodology overview and design principles |
| [AI-DLC Workflows](https://github.com/awslabs/aidlc-workflows) | Official AIDLC workflow definitions |

## License

This project is licensed under the MIT-0 (MIT No Attribution) License. See [LICENSE.md](LICENSE.md) for details.

## Contributing

We welcome contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
