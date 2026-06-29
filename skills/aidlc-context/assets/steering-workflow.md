# Steering: Workflow — Output Template

Generate `{STEERING_DIR}/aidlc-workflow.md` with this structure.

Replace `{feature}`, `{language}`, `{SPECS_DIR}`, `{SKILL_DIR}`, `{STEERING_DIR}` with actual values.

**Kiro only**: Add `inclusion: always` YAML front-matter.

```markdown
# AI-DLC Workflow Active — {feature}

## ⚠️ MANDATORY — Read Every Turn

This project uses AI-DLC skills for specification and implementation. Follow the skill workflow — do NOT generate spec artifacts outside of it.

- **Manifest**: `.aidlc/workflow/{feature}/aidlc-manifest.yaml`
- **Specs**: `{SPECS_DIR}/{feature}/`
- **Workflow**: `.aidlc/workflow/{feature}/`

## Available Skills

| Skill | Phase | What it does |
|---|---|---|
| aidlc-context | 1 | Workspace scan, context assessment, steering files |
| aidlc-requirements | 2 | User stories with EARS acceptance criteria |
| aidlc-decomposition | 3 | Unit breakdown with DDD boundaries and dependencies |
| aidlc-design | 4 | Technology decisions and architecture |
| aidlc-tasks | 5 | Implementation task planning with execution waves |
| aidlc-implement | 6 | Code generation following design specs |
| aidlc-prototype | — | Quick throwaway prototype to validate requirements |
| aidlc-reverse-engineer | — | Deep brownfield codebase analysis (13 reports) |
| aidlc-solutions-review | — | Cross-unit design review for conflicts and alignment |
| aidlc-code-review | — | Code review against design specs and best practices |

## Recovery (after context compaction)

1. Read `.aidlc/workflow/{feature}/aidlc-manifest.yaml` for current state
2. Read steering files at `{STEERING_DIR}/` for project context
3. Activate the **aidlc** orchestrator skill (`{PLATFORM_DIR}/skills/aidlc/SKILL.md`) and execute `resume` — this ensures proper routing, scope checks, unit dashboard, and template re-reading
4. The orchestrator will dispatch the correct phase skill based on manifest state

## Behavioral Anchors

⛔ These rules apply at ALL times, regardless of session length or context size:

1. **Decision gates are mandatory** — generate with blank Answer: fields → present → STOP → wait for user to say "done" or "use recommendations" → THEN generate artifacts
2. **Every 🔲 Your turn block is a hard stop** — do NOT continue until the user responds
3. **Implementation mode requires explicit user choice** — never auto-select standard/parallel/autonomous
4. **Read templates from disk before generating** — never reproduce from memory
5. **Language compliance** — all narrative output in manifest `language` field
6. **Update manifest after every phase** — status, timestamps, sharedPhases

If you notice yourself skipping any of these: STOP, re-read the current skill's SKILL.md, and present the checkpoint you missed.

## Current State

- **Feature**: {feature}
- **Language**: {language}
- **Specs**: `{SPECS_DIR}/{feature}/`

## Implementation Context

When implementing tasks, read design documents first:
- `design.md` — architecture overview
- `design/components.md` — component specs
- `design/data-model.md` — entities and schemas
- `design/api-spec.md` — endpoints and contracts
- `design/integration.md` — external services
- `design/implementation.md` — directory structure and conventions
- `design/testing-strategy.md` — testing architecture and coverage mapping (if exists)

Follow technology stack and patterns from design decisions. Follow testing approach from D4 decisions.
```
