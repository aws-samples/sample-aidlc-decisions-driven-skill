# Action: Detect Build Configuration

## 1. Scan project for build tooling

Check for configuration files and determine the build stack:

| File | Ecosystem | Build Command | Test Command |
|---|---|---|---|
| `package.json` | Node.js | `npm run build` / `yarn build` | `npm test` / `yarn test` |
| `Makefile` | Make-based | `make build` | `make test` |
| `Cargo.toml` | Rust | `cargo build --release` | `cargo test` |
| `pom.xml` | Java/Maven | `mvn package` | `mvn test` |
| `build.gradle` | Java/Gradle | `gradle build` | `gradle test` |
| `pyproject.toml` | Python | `python -m build` | `pytest` |
| `go.mod` | Go | `go build ./...` | `go test ./...` |
| `Dockerfile` | Container | `docker build .` | (embedded in build) |

Read the detected config file(s) to extract:
- Available scripts/targets (especially: build, test, lint, typecheck, format)
- Test frameworks in use
- Coverage configuration
- Lint/format tools configured

## 2. Check for CI configuration (informational)

Scan for existing CI config to understand what the project expects:
- `.github/workflows/*.yml` — GitHub Actions
- `.gitlab-ci.yml` — GitLab CI
- `Jenkinsfile` — Jenkins
- `buildspec.yml` — AWS CodeBuild
- `.circleci/config.yml` — CircleCI
- `azure-pipelines.yml` — Azure DevOps

If found, note the CI stages for reference (the deploy skill will use this).

## 3. Present detected configuration

```
📍 Build Configuration Detected

**Ecosystem**: {ecosystem}
**Build**: `{build command}`
**Test**: `{test command}`
**Lint**: `{lint command or "not configured"}`
**Type-check**: `{typecheck command or "not configured"}`
**Coverage**: `{coverage tool or "not configured"}`
**CI**: `{CI platform or "none detected"}`

Quality gates I'll check:
- {list of applicable gates based on what's configured}

🔲 **Your turn**:
- ✅ "proceed" — run the build and tests
- 🔧 "adjust" — modify commands or add quality gates
- ⏭️ "skip [gate]" — skip specific quality checks
```

**STOP and wait.**

## 4. On user response

- "proceed" / "go" / "yes" → load `{SKILL_DIR}/actions/verify.md`
- "adjust" → user provides overrides, update configuration, re-present
- "skip [gate]" → mark that gate as skipped, proceed

## 5. Audit entry

```
### [{ISO timestamp}] Build: Detection

**Phase**: build
**Action**: build-detect
**Artifacts**: (none — detection only)
**Outcome**: Detected {ecosystem} with {N} quality gates configured.
```
