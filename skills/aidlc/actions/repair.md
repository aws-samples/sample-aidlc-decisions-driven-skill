# Action: repair

## Manifest Repair

When user says "repair", "fix manifest", or "rebuild manifest":

1. Ask user for the feature name (or detect from `{SPECS_DIR}/` folders)
2. Scan disk artifacts at conventional paths:
   - `{SPECS_DIR}/{feature}/context.md` → context phase
   - `{SPECS_DIR}/{feature}/requirements.md` → requirements phase
   - `{SPECS_DIR}/{feature}/units.md` → decomposition phase
   - `{SPECS_DIR}/{feature}/design.md` + `design/` → design phase
   - `{SPECS_DIR}/{feature}/tasks.md` → tasks phase
   - `{SPECS_DIR}/{feature}/deployment.md` → deploy specification (if present)
   - `{SPECS_DIR}/{feature}/units/*/` → unit-scoped artifacts (incremental mode)
   - `{BLUEPRINTS_DIR}/` (project-level) → steering content (product/tech/structure/resources/corrections)
3. Read each found artifact's Summary section to extract key metadata
4. Rebuild the manifest:
   - Set `version: "1.0.0"`, `feature`, `platform` (use the **live platform** — where repair is running)
   - Add each found artifact to `artifacts` with `status: "approved"` and current timestamp
   - Populate `context-summary` from context.md Summary
   - Populate `decisions` from any found `decisions-*.md` files (read Decisions Summary sections)
   - Detect mode from units.md existence (incremental if units exist, comprehensive otherwise)
   - For incremental: scan `{SPECS_DIR}/{feature}/units/*/` to rebuild `units[]` entries with per-unit artifacts
   - Set `state.status` to `"active"`
   - Determine `sharedPhases` from which shared artifacts exist
5. Write the rebuilt manifest to `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`
6. **Ensure the platform shim**:
   - If blueprints exist but the current platform's shim (`{SHIM}`) is missing → generate it (load `{SKILL_DIR}/actions/adapt.md`).
   - If a legacy (pre-blueprints) layout is detected (steering content at `{STEERING_DIR}/`, no/incomplete blueprints) → recommend `upgrade` to migrate the structure (content → blueprints, regenerate shim, remove stale files).
   - If both are missing → the context phase has not run; recommend `start` or the `context` phase.
7. Present what was reconstructed:

```
📍 Manifest Repaired

Reconstructed from disk artifacts:
- {list of phases detected with artifact counts}
- Mode: {incremental / comprehensive}
{If incremental: "Units: {list with detected status}"}
- Blueprints: {found / missing} at `.aidlc/blueprints/`
- Platform shim: {present / regenerated for {live platform} / needs `adapt` / legacy layout → run `upgrade`}

⚠️ Artifact statuses set to "approved" by default. Review and adjust if any are still drafts.

👉 Next: {recommendation based on reconstructed state}
```

**STOP and wait.**

---

## Fallback (No Manifest)

When no manifest exists, scan the filesystem for artifacts at conventional paths:

| Check | Path | Indicates |
|---|---|---|
| `{SPECS_DIR}/{feature}/context.md` | exists | Context phase done |
| `{SPECS_DIR}/{feature}/requirements.md` | exists | Requirements phase done |
| `{SPECS_DIR}/{feature}/units.md` | exists | Decomposition phase done |
| `{SPECS_DIR}/{feature}/design.md` | exists | Design phase done |
| `{SPECS_DIR}/{feature}/tasks.md` | exists | Tasks phase done |
| `{SPECS_DIR}/{feature}/tasks.md` | has `[x]` checkboxes | Implementation in progress |

If no feature directories exist under `{SPECS_DIR}/`:
```
No existing workflow found. Starting fresh.
```

Then dispatch `aidlc-context`.

If artifacts found, present what was detected and dispatch the next skill based on what's missing.
