# Claude Code Integration — Output Template

Generate `{PROJECT_ROOT}/.claude/CLAUDE.md` with this structure. **Claude Code only.**

Replace `{feature}`, `{language}`, `{currentPhase}` with actual values.
Update after each phase completion.

```markdown
# AI-DLC Workflow Context

This project uses AI-DLC skills for structured software specification and implementation.

## Current Workflow State

- **Feature**: {feature}
- **Phase**: {currentPhase}
- **Language**: {language}

## Workflow Instructions

1. **Read manifest**: `.aidlc/workflow/{feature}/aidlc-manifest.yaml` for current state
2. **Activate skill**: Use the skill for the current phase (see Available Skills below)
3. **Decision gates**: WAIT for user approval after each phase
4. **Steering files**: Read `.claude/steering/*.md` for persistent project context

## Available Skills

| Skill | Phase | What it does |
|---|---|---|
| aidlc-context | 1 | Workspace scan, context assessment |
| aidlc-requirements | 2 | User stories with EARS criteria |
| aidlc-decomposition | 3 | Unit breakdown with DDD boundaries and dependencies |
| aidlc-design | 4 | Technology decisions and architecture |
| aidlc-tasks | 5 | Implementation task planning |
| aidlc-implement | 6 | Code generation |
| aidlc-prototype | — | Quick throwaway prototype |
| aidlc-reverse-engineer | — | Deep brownfield codebase analysis (13 reports) |
| aidlc-solutions-review | — | Cross-unit design review for conflicts and alignment |
| aidlc-code-review | — | Code review against design specs and best practices |

## Key Paths

- **Specs**: `.aidlc/specs/{feature}/`
- **Workflow**: `.aidlc/workflow/{feature}/`
- **Manifest**: `.aidlc/workflow/{feature}/aidlc-manifest.yaml`
- **Steering**: `.claude/steering/`

## After Context Compaction

1. Read `.claude/CLAUDE.md` (this file) for current state
2. Read `.aidlc/workflow/{feature}/aidlc-manifest.yaml` for detailed state and artifact paths
3. Read steering files: `.claude/steering/product.md`, `tech.md`, `structure.md`
4. Activate the skill for the current phase
5. Resume from manifest state

## Notes

- Generate ALL content in `{language}` (except code, paths, tech names)
- WAIT for user approval after each phase
- Update `.claude/CLAUDE.md` after each phase completion
```
