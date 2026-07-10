# Platform Shim: Claude Code — Output Template

Generate `{PROJECT_ROOT}/.claude/CLAUDE.md` — the thin Claude Code entry point. **Claude Code only.**

This shim is NOT project content. It carries the behavioral anchors inline (safety-critical, must load reliably) and imports the canonical project content from `.aidlc/blueprints/`. It is static and project-level — it does not change per feature or per phase. Feature state lives in the manifest, not here.

**Import path rule (critical):** Claude Code resolves `@` imports relative to the directory containing `CLAUDE.md` (i.e. `.claude/`), NOT the repo root. Blueprint imports must therefore climb out of `.claude/` with `@../`. A wrong path fails silently — no error, the import just does not load. Always write `@../.aidlc/blueprints/...`.

Replace `{SPECS_DIR}` with the actual value.

```markdown
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
<!-- @../ climbs out of .claude/ to the repo root — required for imports to resolve. -->
@../.aidlc/blueprints/product.md
@../.aidlc/blueprints/tech.md
@../.aidlc/blueprints/structure.md
@../.aidlc/blueprints/resources.md
@../.aidlc/blueprints/corrections.md

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
2. Project content is imported above (blueprints); design docs at `{SPECS_DIR}/{feature}/`
3. Activate the **aidlc** orchestrator (`.claude/skills/aidlc/SKILL.md`) and run `resume` — it routes to the correct phase skill based on manifest state
```

## Rules
- This file is regenerated only when behavioral anchors change or blueprint references change — not per feature.
- If the file already exists, preserve it unless anchors/imports need updating (it holds no project content to lose).
- Every blueprint import MUST use the `@../` prefix. Because failure is silent, `doctor` should verify each import path resolves to an existing file.
- `.claude/rules/` is no longer used for AI-DLC project content — blueprints replace it.
