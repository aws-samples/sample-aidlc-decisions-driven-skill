---
inclusion: always
---
# AI-DLC Project Context

This project uses AI-DLC skills for specification and implementation. Follow the skill workflow — do NOT generate spec artifacts outside of it.

## Behavioral Anchors (apply every turn)

⛔ These rules apply at ALL times, regardless of session length or context size:

1. **Decision gates are mandatory** — generate with blank Answer: fields, present, STOP, wait for the user to say "done" or "use recommendations", THEN generate artifacts
2. **Every 🔲 Your turn block is a hard stop** — do NOT continue until the user responds
3. **Implementation mode requires explicit user choice** — never auto-select standard/parallel/autonomous
4. **Read templates from disk before generating** — never reproduce from memory
5. **Language compliance** — all narrative output in the manifest `language` field
6. **Update the manifest after every phase** — status, timestamps, sharedPhases

If you notice yourself skipping any of these: STOP, re-read the current skill's SKILL.md, and present the checkpoint you missed.

## Project Context

<!-- Canonical content lives in .aidlc/blueprints/ (portable, single source of truth). -->
#[[file:.aidlc/blueprints/product.md]]
#[[file:.aidlc/blueprints/tech.md]]
#[[file:.aidlc/blueprints/structure.md]]
#[[file:.aidlc/blueprints/resources.md]]

## Available Skills

| Skill | Phase | What it does |
|---|---|---|
| aidlc-context | 1 | Workspace scan, context assessment, blueprints |
| aidlc-requirements | 2 | User stories with EARS acceptance criteria |
| aidlc-decomposition | 3 | Unit breakdown with DDD boundaries and dependencies |
| aidlc-design | 4 | Technology decisions and architecture |
| aidlc-tasks | 5 | Implementation task planning with execution waves |
| aidlc-implement | 6 | Code generation following design specs |
| aidlc-build | 7 | Integration build, test suites, quality gates |
| aidlc-deploy | 8 | CI/CD pipeline and deployment configuration |
| aidlc-prototype | — | Quick throwaway prototype to validate requirements |
| aidlc-reverse-engineer | — | Deep brownfield codebase analysis |
| aidlc-solutions-review | — | Cross-unit design review |
| aidlc-code-review | — | Code review against design specs |

## Recovery (after context compaction or session break)

1. Active workflows: read `.aidlc/workflow/*/aidlc-manifest.yaml` for current state (feature, phase, artifacts)
2. Project content is referenced above (blueprints); design docs at `.aidlc/specs/{feature}/`
3. Activate the **aidlc** orchestrator (`.kiro/skills/aidlc/SKILL.md`) and run `resume` — it routes to the correct phase skill based on manifest state
