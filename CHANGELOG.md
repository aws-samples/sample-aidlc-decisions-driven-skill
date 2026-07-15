# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.1] — 2026-07-15

### Fixed

- **Decision gates (D1–D5)**: the Decisions Summary section is now populated on the manual "done" path, not only on "use recommendations" — manually filled answers were validated against an empty summary and silently lost. Gates also stop and list unanswered questions instead of proceeding with blanks. D5 gained the response-handling block it was missing entirely.
- **aidlc-code-review**: `apply-fixes` no longer uses `git stash` as a safety checkpoint — stashing removed the (typically uncommitted) implementation under review and `stash drop` deleted it permanently. Fixes are now backed up to `{WORKFLOW_DIR}/{feature}/history/` and restored from there on test failure.
- **aidlc-implement**: context recovery now resumes parallel/autonomous runs from `implementation.currentWave` (previously a dead end — recovery only understood `currentTask`); both wave modes advance `currentWave` after each wave; parallel mode checks sub-agent reports and presents failed tasks for retry/fix/skip instead of marking every wave task complete. Also fixed autonomous mode's broken "Finalize in SKILL.md" pointer and its double final-summary.
- **aidlc-build**: the manifest is no longer marked `approved` before the user approves the build report — the report is tracked as `draft` and flips to `approved`/`approved-with-warnings` only on approval. Context recovery uses the manifest instead of report-header states that were never produced.
- **aidlc-deploy**: D5-5 (Environment Promotion) is now stored in `decisions.deploy` (was dropped — generation required it from the manifest where it never existed). Context recovery can no longer route into `finalize` — which marks the whole workflow complete without stopping — before the generated files were approved.
- **aidlc-prototype**: "update requirements" backs up `requirements.md` to `history/` before editing (per the shared Edit Action Pattern), giving "revert" a real restore source; inline-story runs without a requirements file get a create-or-ask path; post-approval routing is now explicit.

### Added

- **scripts/validate.sh — Defect Pattern Guards (Check 11)**: fails if any skill instruction uses `git stash` as a checkpoint, or if a decision gate lacks the Decisions Summary population instruction. Negative-tested against the pre-fix file versions.

## [1.2.0] — 2026-07-10

### Added

- **Portable blueprints**: canonical, platform-agnostic project content now lives once at `.aidlc/blueprints/` (`product.md`, `tech.md`, `structure.md`, `resources.md`, `corrections.md`). Travels with `.aidlc/` — no per-platform duplication.
- **Platform shim**: a thin per-platform entry point that carries the behavioral anchors inline and references the blueprints — Kiro `.kiro/steering/aidlc.md` (`#[[file:.aidlc/blueprints/*.md]]`), Claude Code `.claude/CLAUDE.md` (`@../.aidlc/blueprints/*.md`). Both shims can coexist for mixed-platform teams.
- **`adapt` command**: generates the current platform's shim from existing blueprints — for moving a project between Kiro and Claude Code, or a mixed-platform team.
- **`upgrade` command**: migrates a pre-blueprints project to the new structure — moves legacy steering into blueprints, regenerates the shim, and removes the superseded files after confirmation.
- **Live-platform detection + Platform Check**: the orchestrator detects the running platform (authoritative over the manifest `platform` field) and, on resume, routes a legacy layout to `upgrade` and a platform switch to `adapt`.

### Changed

- **Steering content location**: moved from per-platform `.kiro/steering/*` and `.claude/rules/*` into `.aidlc/blueprints/`. The context phase now generates blueprints + a platform shim; all downstream skills (requirements, design, tasks, implement, build, deploy, code-review, prototype) read/write blueprints.
- **Context recovery**: reads the platform shim + blueprints (behavioral anchors stay inline in the shim so they load reliably).
- **Orchestrator**: `doctor` verifies blueprints + shim (including Claude `@../` import resolution) and flags legacy layouts; `repair` scans blueprints and ensures the shim.
- **Docs + example**: `artifacts.md`, `manifest-schema.md`, `context-recovery.md`, `context-rot.md`, `skill-anatomy.md`, `skills/aidlc/README.md`, the presentation, and the todo-app example restructured to the blueprints + shim model. Manifest `steering.updatedBy` key name retained (now tracks blueprint content).

### Fixed

- **skills/aidlc/actions/doctor.md**: Check 6 no longer requires the removed `metadata.version` front-matter field (would otherwise flag every skill).
- **scripts/validate.sh**: fixed the asset-reference check — its regex omitted the `{...}` braces, so it had been silently matching nothing. Also added reference-file (`{REFS}/`), cross-skill-reference (`skills/aidlc-*/assets`), and example blueprints/shim checks.

### Migration

- **Existing (pre-1.2.0) projects**: run `upgrade`. It moves legacy steering (`.kiro/steering/*` or `.claude/rules/*`) into `.aidlc/blueprints/`, generates the platform shim, and removes the stale files after you confirm. `doctor` detects the legacy layout and points you to `upgrade`.

## [1.1.0] — 2026-07-07

### Added

- **Deploy: Deployment specification step**: Added a new planning step between the D5 decision gate and config generation. The deploy skill now produces `deployment.md` in `{SPECS_DIR}/{feature}/` as the source of truth for deployment architecture before generating any pipeline or IaC files.
- **Deploy: Asset template**: Added `skills/aidlc-deploy/assets/deployment.md` template following the same pattern as design skill templates. Covers pipeline architecture, target infrastructure, promotion flow, security, operations integration, rollback, migrations, files to generate, risk assessment, and cost estimate.
- **Deploy: Plan conformance rule**: The generate step now reads and follows the approved `deployment.md` spec as its authoritative source. Deviations require user confirmation.

### Changed

- **Deploy: 4-step process**: Deploy skill process table updated from 3 steps (decision-gate → generate → finalize) to 4 steps (decision-gate → plan → generate → finalize)
- **Deploy: Artifact location**: Deployment specification (`deployment.md`) now lives in `{SPECS_DIR}/{feature}/` alongside other spec artifacts (context, requirements, design, tasks) instead of the workflow directory
- **Deploy: generate.md cleanup**: Removed duplicate `deploy-summary.md` generation from generate step — summary is now only produced during finalization (where it belongs)
- **Todo-app example**: Updated to use AWS solutions (ECS Fargate, ALB, RDS, ECR, Terraform) instead of GCP (Cloud Run, Cloud SQL)
- **Versioning**: Removed per-skill version numbers from all SKILL.md frontmatter and activation messages. Project uses a single version (CHANGELOG + README badge) since skills are installed as a unit.

### Fixed

- **Deploy: generate.md**: Removed duplicate deploy-summary.md generation that conflicted with finalize.md (summary was being written in both steps)

## [1.0.1] — 2026-07-03

### Fixed

- **Documentation**: Corrected manifest version reference in CHANGELOG (was "v2.2", actual schema is v1.0.0)
- **Decision gates**: Replaced stale "DF" (legacy foundation gate) references with "D5" in `shared/decision-gate.md` and `aidlc-requirements/actions/decision-gate.md`
- **README**: Context rot prevention description now correctly states steering file anchors as primary mechanism (hooks are optional)
- **README**: Changed "three phases" to "three stages" to avoid confusion with the 8 individual workflow phases
- **docs/context-rot.md**: Removed duplicate "Behavioral Anchors in Steering Files" section, renumbered remaining sections
- **examples/todo-app**: Fixed self-contradictory D5 statement in README, added `decisions-deploy.md` to structure tree
- **examples/todo-app**: Created missing `decisions-deploy.md` file (referenced by audit trail but absent from disk)
- **examples/todo-app**: Added missing `scope: new` field to example manifest's state block (required by schema)
- **powers/aidlc/POWER.md**: Added missing `scope [name]` command to command table
- **powers/aidlc/POWER.md**: Corrected decision gate coverage claim to exclude Implement phase (Context, Implement, and Build have no gate)
- **skills/aidlc/actions/doctor.md**: Added `aidlc-build` and `aidlc-deploy` to skill checklist (optional), added `scopes.md` to shared resources check
- **skills/aidlc/README.md**: Removed "v2" from title and opening paragraph (no other file uses this versioning)
- **scripts/validate.sh**: Moved `aidlc-build` and `aidlc-deploy` from core to optional skills (aligning with SKILL.md orchestrator behavior)
- **CONTRIBUTING.md**: Clarified "13 skills" to "12 phase/supporting skills + the orchestrator"

## [1.0.0] — 2026-06-30

### Added

- **Core workflow**: 8 phase skills (context, requirements, decomposition, design, tasks, implement, build, deploy)
- **Orchestrator**: manifest-driven routing, status, rollback, resume, repair, doctor, quick path
- **Supporting skills**: prototype, reverse-engineer, solutions-review, code-review
- **Decision gates**: D1 (requirements), D2 (decomposition), D3 (design + observability), D4 (tasks), D5 (deploy + IaC)
- **Operations design**: logging, health checks, graceful shutdown, metrics, alerting as first-class design output (D3-Ops questions, `design/operations.md` template, observability-patterns reference)
- **Platform-specific deploy**: GitHub Actions and GitLab CI templates by stack (Node, Python, Java, Go) with deploy targets (Cloud Run, ECS, K8s, Lambda)
- **Infrastructure as Code**: Terraform and AWS CDK reference catalogs with production patterns
- **Scope-adaptive workflow**: auto-detects new/feature/bugfix/refactor, adjusts active phases
- **Incremental delivery**: decompose complex projects into units, design and implement independently
- **Parallel implementation**: wave-based sub-agent dispatch with file ownership isolation
- **Multi-platform**: Kiro (IDE + CLI) and Claude Code support
- **Multi-language**: all artifacts generated in user's detected language
- **Context recovery**: manifest + steering files enable session resume without lost progress
- **Context rot prevention**: behavioral anchors in steering files, skill handoff identity reset
- **Traceability enforcement**: requirements → design → tasks gap detection with fail conditions
- **Version resolution**: web search for current stable versions during design generation
- **Learning loop**: human corrections persist as project rules in `corrections.md`
- **Validation script**: `scripts/validate.sh` for verifying cross-references
- **Example**: complete todo-app workflow output with all artifacts
- **Example requirements**: English and Thai business requirements for testing

### Architecture

- Hub-and-spoke orchestrator with layered instruction loading (base → SKILL.md → actions)
- Manifest v1.0.0 as single source of truth for workflow state
- Shared base (~100 lines) loaded once per session, §Summary for chained dispatch
- Action files loaded on-demand per step (not upfront)
- Asset templates define output structure; reference catalogs loaded conditionally by stack/target
