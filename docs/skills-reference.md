# Skills Reference

## Core Workflow (in order)

| Skill | AIDLC Phase | Stage | What It Does |
|---|---|---|---|
| `aidlc-context` | Inception | 1 | Scans workspace, detects stack and architecture (brownfield) or captures intent (greenfield). Produces `context.md`, blueprints, and the platform shim. Creates the manifest. |
| `aidlc-requirements` | Inception | 2 | Translates context into user stories with EARS acceptance criteria. Generates personas (optional). Routes to decomposition, design, or prototype based on complexity. |
| `aidlc-decomposition` | Inception | 3 | Breaks requirements into independently deliverable units using DDD concepts. Defines boundaries, dependencies, and development sequence. Proposes a foundation unit for shared scaffolding when needed. Presents incremental vs. comprehensive mode choice. |
| `aidlc-design` | Construction | 4 | Makes technology decisions via D3 decision gate. Generates component design, data model, API spec, integration patterns, implementation plan, and operations design (logging, health, metrics). Supports compact (≤10 stories) and modular (11+) formats. |
| `aidlc-tasks` | Construction | 5 | Breaks design into sequenced, estimable tasks. Generates execution waves with file ownership for parallel dispatch. |
| `aidlc-implement` | Construction | 6 | Executes tasks in standard (one-at-a-time), parallel (wave-based sub-agents), or autonomous (all waves, no stops) mode. |
| `aidlc-build` | Operation | 7 | Detects build tooling, runs final integration build, executes full test suites, validates quality gates (lint, type-check, security, coverage). Produces build report. |
| `aidlc-deploy` | Operation | 8 | Generates CI/CD pipeline configs and optional IaC (Terraform/CDK) via D5 decision gate. Handles environment promotion, secrets management, rollback strategy, database migrations, and post-deploy verification. Platform-specific templates for GitHub Actions, GitLab CI. |

## Supporting Skills

| Skill | What It Does |
|---|---|
| `aidlc-reverse-engineer` | Deep brownfield codebase analysis. Extracts architecture, modules, data models, API surface, business rules, features, integrations, conventions, and technical debt. Output is project-scoped (`.aidlc/reverse-engineer/`) and shared across all features. |
| `aidlc-prototype` | Builds a throwaway spike to validate requirements. No architecture, no tests, hardcoded data. Code goes to `.aidlc/prototype/`. |
| `aidlc-solutions-review` | Cross-unit design review. Compares 2+ unit designs for architectural conflicts, technology mismatches, integration gaps, and duplication. |
| `aidlc-code-review` | Reviews implemented code against design specs, security best practices, performance, test coverage, and coding standards. Produces severity-classified findings with suggested fixes. |
| `aidlc` | Workflow orchestrator. Reads manifest state, dispatches to phase skills by loading their SKILL.md, manages rollback and status display. One activation drives the entire workflow. |
