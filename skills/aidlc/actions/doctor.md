# Action: doctor

Perform a comprehensive health check of the AI-DLC installation. Validates skill files, cross-references, shared resources, and optional workflow state.

## Process

Run all checks sequentially. Collect results, then present a single report.

### Check 1: Core Skills

Verify required skill directories and SKILL.md files exist:

| Skill | Required |
|---|---|
| `aidlc-context` | Yes |
| `aidlc-requirements` | Yes |
| `aidlc-design` | Yes |
| `aidlc-tasks` | Yes |
| `aidlc-implement` | Yes |
| `aidlc-build` | No |
| `aidlc-deploy` | No |
| `aidlc-decomposition` | No |
| `aidlc-prototype` | No |
| `aidlc-reverse-engineer` | No |
| `aidlc-solutions-review` | No |
| `aidlc-code-review` | No |

For each, check `{PLATFORM_DIR}/skills/{skill}/SKILL.md` exists and is readable.

### Check 2: Shared Resources

Verify shared files exist:
- `{PLATFORM_DIR}/skills/aidlc/shared/base.md`
- `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md`
- `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md`

### Check 3: Action File References

For each installed skill's SKILL.md, read the Process table and extract action file paths. Verify each referenced action file exists:
- Pattern: `{SKILL_DIR}/actions/*.md`

### Check 4: Asset File References

For each installed skill's action files, scan for asset references (`{ASSETS_DIR}/*.md`). Verify each referenced asset file exists in the skill's `assets/` directory.

### Check 5: Reference File References

For each installed skill's action files, scan for reference file paths (`{REFERENCES_DIR}/*.md`). Verify each exists in the skill's `references/` directory.

### Check 6: SKILL.md Front-Matter

For each installed skill, verify SKILL.md has valid YAML front-matter with:
- `name` field present
- `description` field present
- `metadata.version` field present

### Check 7: Workflow State (if exists)

If manifests exist at `{WORKFLOW_DIR}/*/aidlc-manifest.yaml`:
- Validate manifest structure (same checks as Manifest Validation in SKILL.md)
- Check referenced artifact files exist on disk
- Check for stale artifacts (status = "approved" but file missing)

### Check 8: Steering Files (if exist)

If `{STEERING_DIR}/` exists, verify expected files:
- `aidlc-workflow.md` — required if any manifest exists
- `product.md`, `tech.md`, `structure.md` — expected after context phase

---

## Report Format

```
📍 AI-DLC Doctor — Installation Health Check

Platform: {platform}
Skills directory: {PLATFORM_DIR}/skills/

## Core Skills
  ✅ aidlc-context
  ✅ aidlc-requirements
  ✅ aidlc-design
  ✅ aidlc-tasks
  ✅ aidlc-implement

## Optional Skills
  ✅ aidlc-decomposition
  ✅ aidlc-prototype
  ✅ aidlc-reverse-engineer
  ✅ aidlc-solutions-review
  ✅ aidlc-code-review

## Shared Resources
  ✅ aidlc/shared/base.md
  ✅ aidlc/shared/decision-gate.md

## Cross-References
  ✅ {X} action files verified
  ✅ {Y} asset files verified
  ✅ {Z} reference files verified
  {If issues: ❌ Missing: {path} (referenced by {source})}

## Front-Matter
  ✅ All {N} skills have valid metadata

## Workflow State
  {If no manifests: "— No active workflows"}
  {If manifests:
    ✅ {feature}: manifest valid, {X} artifacts on disk
    ⚠️ {feature}: {issue description}
  }

## Steering Files
  {If no steering dir: "— No steering files (expected before first workflow)"}
  {If exists: ✅ / ⚠️ per file}

─────────────────────────────────────────
Summary: {errors} errors, {warnings} warnings

{If clean: "✅ Installation healthy — all checks passed."}
{If warnings only: "⚠️ Installation functional with warnings. Review items above."}
{If errors: "❌ Issues found. Fix errors above, then run `doctor` again."}
```

---

## Severity Classification

- **❌ Error**: Skill will fail at runtime (missing required file, broken reference)
- **⚠️ Warning**: Non-critical issue (optional skill missing, stale artifact, missing steering file)
- **✅ Pass**: Check passed

---

## When to Suggest Doctor

The orchestrator should suggest `doctor` when:
- Pre-flight validation finds missing skills
- A skill dispatch fails with "file not found"
- User reports unexpected behavior
- After initial installation ("Run `doctor` to verify your setup")
