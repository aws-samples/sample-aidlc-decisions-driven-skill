# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
- Manifest v2.2 as single source of truth for workflow state
- Shared base (~100 lines) loaded once per session, §Summary for chained dispatch
- Action files loaded on-demand per step (not upfront)
- Asset templates define output structure; reference catalogs loaded conditionally by stack/target
