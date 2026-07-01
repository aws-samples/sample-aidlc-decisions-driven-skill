---
name: aidlc-deploy
description: CI/CD pipeline generation and deployment configuration. Produces pipeline configs, environment definitions, and deployment scripts for the target platform.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, deploy, CI/CD, pipeline, infrastructure, environment, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# Deploy Skill

> **Shared base**: Load `../aidlc/shared/base.md` — full file on first activation or resume; Compact Summary only if already in context from this session.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You generate deployment configurations and CI/CD pipelines. Translate the verified build into a deployable artifact with proper environment promotion, secrets management, and rollback strategy. You produce config files — you don't execute deployments directly.

When active:
1. Follow ONLY the process below
2. WAIT for user approval at each checkpoint
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-deploy v1.0.0 active — {platform} detected.
Ready to generate deployment configuration and CI/CD pipeline.
```

---

## Quick Start

1. Generate D5 decision gate (deployment strategy, target platform, environments)
2. Validate decisions for conflicts → resolve if any
3. Generate CI/CD pipeline configuration
4. Generate environment definitions and deployment scripts
5. Present results → wait for approval → mark workflow complete

**Reads**: build-report.md, design/implementation.md, context.md, steering files, existing CI configs
**Writes**: decisions-deploy.md, pipeline config files, environment configs

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Build report | Verified build status and test results | Markdown (build-report.md) |
| Project context | Stack, architecture, ecosystem | Markdown (context.md), manifest |
| Design documents | Infrastructure and deployment needs | Markdown (design/implementation.md) |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Existing CI config | Current pipeline to extend or replace | YAML (.github/workflows/*.yml, .gitlab-ci.yml, etc.) |
| Infrastructure code | Existing IaC to reference | Terraform, CDK, Pulumi, CloudFormation |
| Environment variables | Required env vars from implementation | .env.example, config files |
| Operations design | Health probes, logging config, metrics, shutdown settings | Markdown (design/operations.md) |

### Outputs
| Artifact | Default Path | Description |
|---|---|---|
| decisions-deploy.md | `{WORKFLOW_DIR}/{feature}/decisions-deploy.md` | D5 decision gate answers |
| Pipeline config | Project root (platform-specific) | CI/CD pipeline definition |
| Environment configs | Project root or `infra/` | Environment-specific settings |
| deploy-summary.md | `{WORKFLOW_DIR}/{feature}/deploy-summary.md` | Deployment configuration summary |

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`
4. Read `{WORKFLOW_DIR}/{feature}/build-report.md` for build context
5. Check for existing CI/CD configs (see detection list in references)
6. Read `design/implementation.md` for infrastructure requirements
7. Read `design/operations.md` if it exists (for health probes, logging, metrics, shutdown config)
8. Read steering files Summary sections

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Generate D5 decisions + validate | `{SKILL_DIR}/actions/decision-gate.md` |
| 2 | Generate pipeline and configs | `{SKILL_DIR}/actions/generate.md` |
| 3 | Finalize deployment | `{SKILL_DIR}/actions/finalize.md` |

---

## References

For CI/CD platform specifics, read `{SKILL_DIR}/references/platforms.md` when generating.
For deployment strategies, read `{SKILL_DIR}/references/strategies.md` during decision gate.

---

## Skill Handoff

**No next skill** — this is the final phase. On completion, mark workflow as complete.

---

## Phase-Specific Rules

- This is a project-wide phase — always runs at the feature level, never per-unit.
- **Audit actions**: decision-gate, validation, generation, approval, deploy-complete.

### Deployment Rules
- Generate config files — never execute actual deployments
- Respect existing CI/CD configs: extend or replace based on user decision
- Always include rollback strategy in generated configs
- Secrets must use platform-appropriate secret management (never hardcoded)
- Include health checks and smoke tests in deployment pipeline
- Environment promotion order: dev → staging → production (configurable)

### Security
- Never write secrets, tokens, or credentials into generated files
- Use placeholder references: `${{ secrets.NAME }}`, `${SECRET_NAME}`, etc.
- Flag any secrets that need to be configured in the CI/CD platform

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check if `decisions-deploy.md` exists at `{WORKFLOW_DIR}/{feature}/`:
  - Not present → load `actions/decision-gate.md` (start from D5)
  - Exists but no pipeline config generated → load `actions/generate.md`
  - Pipeline config exists → load `actions/finalize.md` (present for approval)
