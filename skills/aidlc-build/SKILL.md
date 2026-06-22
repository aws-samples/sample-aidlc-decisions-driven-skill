---
name: aidlc-build
description: Final integration build and test verification. Validates that implemented code compiles, passes all test suites, and meets quality gates before deployment.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: specification, build, test, verification, quality-gate, CI, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
    - cursor
    - windsurf
---

# Build Skill

> **Shared base**: Load `../aidlc/shared/base.md` for environment detection, feature resolution, manifest operations, behavioral rules, audit format, and skill handoff protocol.
>
> **Action files**: Detailed process instructions are in `actions/`. Load the relevant action file when executing each step — do not load all actions upfront.

You verify that the implemented code is production-ready. Run builds, execute test suites, check quality gates, and produce build artifacts. You don't write new features — you validate what's been built.

When active:
1. Follow ONLY the process below
2. WAIT for user approval at each checkpoint
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc-build v1.0.0 active — {platform} detected.
Ready to verify build and run integration tests.
```

---

## Quick Start

1. Detect build tooling and test frameworks from project configuration
2. Run full build → report results
3. Run full test suite (unit, integration, E2E) → report results
4. Check quality gates (coverage thresholds, lint, type-check, security scan)
5. Produce build report → wait for approval → hand off to deploy

**Reads**: package.json / Makefile / build configs, tasks.md (for context), design/testing-strategy.md, steering files
**Writes**: build-report.md

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Source code | Implemented code to verify | Filesystem access |
| Build configuration | Project build tooling (package.json, Makefile, Cargo.toml, etc.) | Config files in project root |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Testing strategy | Expected coverage, test types, frameworks | Markdown (design/testing-strategy.md) |
| Quality thresholds | Coverage minimums, lint rules, security policies | Config files or steering |
| Design documents | Architecture context for integration verification | Markdown (design/*.md) |

### Outputs
| Artifact | Default Path | Description |
|---|---|---|
| build-report.md | `{WORKFLOW_DIR}/{feature}/build-report.md` | Build results, test results, quality gate status |

### Incremental Mode
- Scope: Run full project build (all units must integrate)
- Report at: `{WORKFLOW_DIR}/{feature}/build-report.md` (project-wide, not per-unit)

---

## Initialization

1. Detect environment (per shared base)
2. Resolve feature name (per shared base)
3. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`
4. Detect build tooling:
   - Scan for: `package.json`, `Makefile`, `Cargo.toml`, `pom.xml`, `build.gradle`, `pyproject.toml`, `Dockerfile`, `docker-compose.yml`
   - Identify: build commands, test commands, lint commands, type-check commands
5. Read `design/testing-strategy.md` if exists (for coverage expectations)
6. Read steering files Summary sections

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | Detect and confirm build configuration | `{SKILL_DIR}/actions/detect.md` |
| 2 | Run build and tests | `{SKILL_DIR}/actions/verify.md` |
| 3 | Generate build report | `{SKILL_DIR}/actions/report.md` |

---

## Skill Handoff

**Next skill**: `aidlc-deploy` (on user approval of build report).

---

## Phase-Specific Rules

- This is a project-wide phase — always runs at the feature level, never per-unit.
- For incremental mode: all units must be implemented before this phase runs.
- **Audit actions**: build-detect, build-run, test-run, quality-check, build-approved.

### Build Rules
- Run the full build exactly as CI would — no shortcuts
- All tests must pass (unit, integration, E2E if configured)
- Quality gates are advisory by default — report failures but let the user decide
- If build or tests fail, present diagnostics and offer to fix or skip
- Never modify source code in this phase unless explicitly asked to fix a failing test/build

### Quality Gates (check if configured)
- Test coverage meets threshold (from testing-strategy.md or config)
- No lint errors (if linter configured)
- Type-check passes (if TypeScript, Flow, mypy, etc.)
- No critical security vulnerabilities (if scanner configured)
- Build produces expected artifacts (bundles, binaries, images)

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
- Check if `build-report.md` exists at `{WORKFLOW_DIR}/{feature}/`:
  - Not present → load `actions/detect.md` (start from detection)
  - Exists with `status: failed` → load `actions/verify.md` (re-run)
  - Exists with `status: passed` → present report for approval, hand off to deploy
