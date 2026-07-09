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

### Check 7: Workflow State (if exists)

If manifests exist at `{WORKFLOW_DIR}/*/aidlc-manifest.yaml`:
- Validate manifest structure (same checks as Manifest Validation in SKILL.md)
- Check referenced artifact files exist on disk
- Check for stale artifacts (status = "approved" but file missing)

### Check 8: Blueprints and Platform Shim (if a manifest exists)

**Blueprints** — verify canonical content at `{BLUEPRINTS_DIR}/` (`.aidlc/blueprints/`):
- `product.md`, `tech.md`, `structure.md` — expected after context phase
- `resources.md` — expected after context phase
- `corrections.md` — optional (created on-demand by the learning loop)

**Platform shim** — verify the current platform's entry point exists and references blueprints:
- Kiro: `.kiro/steering/aidlc.md` exists, has `inclusion: always` front-matter, and contains `#[[file:.aidlc/blueprints/*.md]]` references
- Claude Code: `.claude/CLAUDE.md` exists and contains `@../.aidlc/blueprints/*.md` imports
  - **Verify each import resolves** — Claude imports fail silently on wrong paths. For each `@../.aidlc/blueprints/{name}.md`, confirm the target file exists. Flag any that don't as ❌.
- For every blueprint reference in the shim, confirm the referenced blueprint file exists on disk.

**Platform mismatch** — compare the manifest `platform` against the live platform:
- If they differ, or the current platform's shim is missing → ⚠️ warn and recommend `adapt` to generate the current platform's shim (blueprints are shared; no content is regenerated).

### Check 9: Legacy Steering (migration hint)

If legacy per-platform steering content still exists at `{STEERING_DIR}/` (e.g., `{STEERING_DIR}/tech.md`, `product.md`, or `aidlc-workflow.md`):
- ⚠️ Inform that steering content has moved to `{BLUEPRINTS_DIR}/`. Recommend `adapt` (or `repair`) to consolidate, then remove the stale legacy files.

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

## Blueprints & Shim
  {If no manifest: "— No blueprints (expected before first workflow)"}
  {If exists: ✅ / ⚠️ per blueprint file at .aidlc/blueprints/}
  {Platform shim: ✅ present + references resolve | ⚠️ missing for {live platform} → run `adapt`}
  {If platform mismatch (manifest vs live): ⚠️ set up for {manifest.platform}, running {live platform} → run `adapt`}
  {If legacy steering content found at {STEERING_DIR}: ⚠️ migrate to blueprints}

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
