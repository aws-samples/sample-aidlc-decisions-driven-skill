# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
