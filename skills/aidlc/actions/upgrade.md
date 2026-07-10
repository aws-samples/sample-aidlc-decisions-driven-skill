# Action: upgrade (Project Structure Upgrade)

Bring a project's on-disk structure up to date with the current skills version. This is the home for one-directional structure migrations across versions.

**Currently handles**: the pre-blueprints → blueprints migration — moving legacy per-platform steering content into `.aidlc/blueprints/` and replacing the old steering files with a thin platform shim.

**Trigger**: the user says "upgrade"; or `doctor`/`repair` detect a legacy (pre-blueprints) layout.

Distinct from its siblings:
- `repair` rebuilds the **manifest** (workflow state) from disk.
- `adapt` ensures the current platform's **shim** exists, assuming blueprints already exist.
- `upgrade` migrates the **structure itself** old → current, then delegates shim generation to `adapt`.

upgrade migrates by copying (never destructive until the final confirmed cleanup) and never alters content meaning.

---

## 1. Detect the current layout

Determine the live platform (`.kiro/skills/`→Kiro, `.claude/skills/`→Claude Code), then check for legacy structure:

**Kiro legacy** (`.kiro/steering/`):
- Content files: `product.md`, `tech.md`, `structure.md`, `resources.md`, `corrections.md`
- Old shim: `aidlc-workflow.md`

**Claude Code legacy** (`.claude/`):
- Content files: `.claude/rules/{product,tech,structure,resources,corrections}.md`
- Old aggregator: `.claude/CLAUDE.md` **that does NOT contain `@../.aidlc/blueprints/` imports** (an old-style CLAUDE.md holds inline content/rules; the new shim is thin and imports blueprints). If the existing CLAUDE.md already imports blueprints, it is already the new shim — not legacy.

If no legacy files exist and `.aidlc/blueprints/` is present → already current; report and stop.
If nothing exists (no legacy, no blueprints) → context phase has not run; recommend `start` or `context`, and stop.

## 2. Old → New mapping

| Old (Kiro) | Old (Claude Code) | New | Transform |
|---|---|---|---|
| `.kiro/steering/product.md` | `.claude/rules/product.md` | `.aidlc/blueprints/product.md` | copy, strip front-matter |
| `.kiro/steering/tech.md` | `.claude/rules/tech.md` | `.aidlc/blueprints/tech.md` | copy, strip front-matter |
| `.kiro/steering/structure.md` | `.claude/rules/structure.md` | `.aidlc/blueprints/structure.md` | copy, strip front-matter |
| `.kiro/steering/resources.md` | `.claude/rules/resources.md` | `.aidlc/blueprints/resources.md` | copy, strip front-matter |
| `.kiro/steering/corrections.md` | `.claude/rules/corrections.md` | `.aidlc/blueprints/corrections.md` | copy, strip front-matter (if present) |
| `.kiro/steering/aidlc-workflow.md` | `.claude/CLAUDE.md` (old aggregator) | platform shim | discard old; regenerate shim (Step 4) |

## 3. Migrate content → blueprints

For each legacy content file (product, tech, structure, resources, corrections):
- Copy its content to `{BLUEPRINTS_DIR}/{name}.md`, stripping any platform front-matter (e.g. `--- inclusion: always ---`).
- **Preserve content verbatim** — do NOT alter meaning.
- **If a blueprint already exists** (partial prior upgrade): keep the existing blueprint. Do NOT overwrite. If the legacy file differs, report the divergence and let the user reconcile — never silently discard either version.

Do NOT copy the old shim (`aidlc-workflow.md` / old aggregator `CLAUDE.md`) into blueprints — it is superseded by the regenerated shim.

## 4. Generate the platform shim

Load `{SKILL_DIR}/actions/adapt.md` and generate the current platform's shim (referencing the now-present blueprints). adapt owns shim generation — do not duplicate it here.

## 5. Verify before cleanup

- Every migrated content file exists at `{BLUEPRINTS_DIR}/` and matches its legacy source.
- The shim exists and its blueprint references resolve (Claude: verify each `@../.aidlc/blueprints/{name}.md` resolves — imports fail silently on wrong paths).

**Do NOT proceed to cleanup unless every legacy content file is confirmed present in blueprints.**

## 6. Confirmed cleanup of superseded files

Present the exact list of superseded files to remove and **STOP for confirmation** (deletion is destructive):

```
📍 Upgrade — ready to remove superseded files

Migrated to `.aidlc/blueprints/`:
- {list of migrated content files}

Superseded files to remove:
- {legacy content files: .kiro/steering/*.md or .claude/rules/*.md}
- {old shim: .kiro/steering/aidlc-workflow.md, if Kiro}

The new shim `{SHIM}` is in place and references the blueprints.

---
🔲 **Your turn**:
- ✅ "remove" — delete the superseded files listed above
- 🔒 "keep" — leave them (note: on Kiro, leftover `inclusion: always` files will double-load with the shim)
```

**STOP and wait.**

Cleanup rules:
- Remove ONLY the AIDLC-managed legacy files listed above. Never remove the whole `{STEERING_DIR}/` directory or any unrelated files the user placed there.
- Never remove a legacy file whose content was not confirmed migrated (Step 5).
- For Claude: the old aggregator `CLAUDE.md` is replaced in place by the new shim (Step 4), so it needs no separate deletion — just confirm it now imports blueprints.

## 7. Present

```
📍 Project Upgraded — blueprints layout

- Blueprints: {N} files at `.aidlc/blueprints/`
- Shim: {SHIM} (references blueprints)
- Removed: {N legacy files, or "none — kept at user request"}

👉 Next: say "resume" to continue the workflow.
```

## 8. Audit entry

Append to the active feature's `{WORKFLOW_DIR}/{feature}/audit.md` (if a feature is active; upgrade is project-level):

```
### [{ISO timestamp}] Orchestrator: Upgrade

**Action**: upgrade
**Artifacts**: {migrated blueprint files}, {shim path}
**Outcome**: Migrated {N} legacy steering files → blueprints, regenerated {live platform} shim, removed {M} superseded files (or kept at user request).
```
