# Example: Todo App

This directory contains example AI-DLC artifacts for a simple **Todo App** feature. These files show what AI-DLC generates at each phase of the workflow.

## What's Here

| File | Phase | Description |
|------|-------|-------------|
| `context.md` | Context | Project landscape assessment — greenfield TypeScript/Express/PostgreSQL |
| `requirements.md` | Requirements | 5 user stories with EARS acceptance criteria |
| `design.md` | Design | Compact design with architecture, components, data model, API spec |
| `tasks.md` | Tasks | Implementation tasks with execution waves and file ownership |

In a real project, these files would live at `.aidlc/specs/todo-app/`.

## About This Example

- **Project type**: Greenfield
- **Stack**: TypeScript / Express / PostgreSQL / Prisma
- **Complexity**: Simple (5 stories, 1 domain, 1 user type)
- **Design format**: Compact (single file, since ≤10 stories)
- **Workflow path**: Context → Requirements → Design → Tasks → Implement → Build and Test → Deploy

This example follows the simple project path — no decomposition, no foundation, no units. The Build and Test and Deploy stages are not shown in this example as they depend on the target deployment environment. For complex project examples with multiple units and incremental delivery, see the AI-DLC documentation.

## How These Were Generated

Each file was produced by its corresponding AI-DLC skill:

1. `aidlc-context` scanned the workspace and produced `context.md`
2. `aidlc-requirements` translated context into user stories in `requirements.md`
3. `aidlc-design` made technology decisions and produced `design.md`
4. `aidlc-tasks` broke the design into sequenced tasks in `tasks.md`

Decision gates (D1–D4) were answered at each phase but are not included here — they live in the workflow directory during actual use.
