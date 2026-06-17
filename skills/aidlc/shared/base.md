# AI-DLC Shared Base

> **Usage**: Every phase skill references this file for common operations. Load once per session — do not re-read if already in context. Phase-specific SKILL.md files extend (never override) these shared behaviors.

---

## Environment Detection

Detect platform and set path variables:

| Check | Platform | STEERING_DIR | SKILL_DIR base |
|---|---|---|---|
| `.kiro/` exists | Kiro | `.kiro/steering` | `.kiro/skills/` |
| `.claude/` exists | Claude Code | `.claude/steering` | `.claude/skills/` |
| `.cursor/` exists | Cursor | `.cursor/steering` | `.cursor/skills/` |
| `.windsurf/` exists | Windsurf | `.windsurf/steering` | `.windsurf/skills/` |

Derived paths (always):
- `SPECS_DIR` = `.aidlc/specs`
- `WORKFLOW_DIR` = `.aidlc/workflow`
- `ASSETS_DIR` = `{SKILL_DIR}/assets` (where SKILL_DIR = `{PLATFORM_DIR}/skills/aidlc-{current-skill}`)
- `REFERENCES_DIR` = `{SKILL_DIR}/references` (if the skill has references)

---

## Feature Name Resolution

Used during initialization of every phase skill:

1. Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` for existing manifests
2. If exactly one manifest → use its `feature` field
3. If multiple manifests → present list, ask user which feature to work on
4. If no manifests → infer from `{SPECS_DIR}/` folders:
   - Exactly one folder → use it
   - Multiple folders → list and ask
   - None → ask user for feature name

---

## Manifest Operations

### Reading
- Path: `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`
- Silent operation — never narrate to user

### Updating Phase Status
After user approves a phase:
```yaml
artifacts.{phase}.status: "approved"
artifacts.{phase}.timestamp: "{ISO timestamp}"
state.sharedPhases: [...existing, "{phase}"]  # for shared phases only
```

### Marking Downstream Outdated
When a phase artifact is edited after approval, mark all downstream phase artifacts as `status: "outdated"`.

Phase order: context → requirements → decomposition → foundation → design → tasks → implement

### Unit-Scoped Operations (Incremental Mode)
- Unit artifacts: `{SPECS_DIR}/{feature}/units/{unit}/`
- Unit workflow: `{WORKFLOW_DIR}/{feature}/units/{unit}/`
- Unit manifest entries: `units[name={unit}].artifacts.{phase}`

---

## Behavioral Rules

### Language & Presentation
- Content language: match user's language (ISO 639-1 detected from first message)
- Technical terms: always English (paths, code, variable names, phase names)
- Silent operations: never narrate platform detection, manifest reads/writes, file scanning, path resolution, template loading, audit entries

### Tool Preferences by Platform
- **Kiro**: `fsWrite`, `readMultipleFiles`, `readCode`
- **Claude Code**: `Write`/`Edit`, parallel `Read`
- **Cursor/Windsurf**: `Write`/`Edit`, sequential reads

### Context Recovery
If context is lost mid-phase:
1. Read `{STEERING_DIR}/aidlc-workflow.md` → get manifest path and current state
2. Read manifest → get current phase, artifact paths, decisions
3. Re-read current skill's SKILL.md → reload phase instructions
4. Resume from the current action based on manifest state

### Error Handling
- Report clearly: what happened, what to do next
- Offer rebuild/retry
- Never lose work silently
- Optional file reads: if a file doesn't exist, skip silently (expected). If it exists but can't be read, warn: "⚠️ File exists but could not be read: {path}"

---

## Audit Trail

Append to `{WORKFLOW_DIR}/{feature}/audit.md` after significant actions (decision gates, validation, generation, approval, edits).

Standard entry format:
```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: {phase-name}
**Action**: {action-type}
**Artifacts**: {files created or modified}
**Outcome**: {result summary}
```

---

## Skill Handoff

When transitioning to the next phase:

1. Resolve path: `{PLATFORM_DIR}/skills/aidlc-{next-skill}/SKILL.md`
2. Read that file
3. Follow its instructions — begin the next phase in the same conversation
4. The transition is transparent to the user (no announcement needed)

If the skill file cannot be found:
```
👉 Next: Activate the **aidlc-{next-skill}** skill to continue.
```

---

## Decision Gate Protocol

Shared pattern for skills with decision gates (D1, D2, DF, D3, D4):

1. **Generate**: Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for structure. Generate with blank `Answer:` fields — never pre-fill.
2. **Present**: Show file path, offer "use recommendations" option. **STOP — do NOT continue.**
3. **Validate**: After answers filled, check conflict rules (defined per-skill). Present conflicts grouped by severity (🔴 → 🟡 → 🟢).
4. **Resolve**: User picks resolution option for each conflict. Log in audit.
5. **Store**: Write compact decision summary to manifest `decisions.{phase}` (or `units[].decisions.{phase}` for incremental).
6. **Proceed**: Continue to generation action.

**⛔ HARD RULE — NEVER auto-fill decisions:**
- You MUST NOT fill `Answer:` fields yourself, even if the choices seem obvious or straightforward.
- You MUST NOT proceed past step 2 until the user explicitly says "done" or "use recommendations".
- The purpose of decision gates is to give the human control. Skipping this defeats the entire workflow.
- If the project seems simple, say so in your presentation — but still STOP and wait for the user.

User can say "skip validation and proceed" → log warning in audit, proceed anyway.

---

## Output Path Scoping (Skills with Unit Support)

For design and tasks skills operating in incremental mode:

- **Comprehensive mode** (or no units): write to `{SPECS_DIR}/{feature}/`
- **Incremental mode** (specific unit): write to `{SPECS_DIR}/{feature}/units/{unit}/`

**NEVER write unit-scoped artifacts to the shared `{SPECS_DIR}/{feature}/` directory.** Shared directory is reserved for project-wide artifacts (context.md, requirements.md, units.md, foundation.md).

---

## Edit Action Pattern

Standard pattern for all phase artifact edits (design-edit, requirements-edit, foundation-edit, etc.):

1. **Backup**: Copy files being modified to `{WORKFLOW_DIR}/{feature}/history/{filename}-{ISO-timestamp}.md`
2. **Apply**: Read current artifact, apply requested changes
3. **Re-validate**: Run the phase's validation checks (defined per-skill)
4. **Cascade**: If change affects related files, update ALL affected artifacts (e.g., renaming an entity cascades to data-model, api-spec, components)
5. **Mark outdated**: Set all downstream phase artifacts to `status: "outdated"` in manifest
6. **Present**: Show what changed with `🔲 **Your turn**` block
7. **STOP** — wait for approval
