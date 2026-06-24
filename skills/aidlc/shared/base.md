# AI-DLC Shared Base

> **Usage**: Every phase skill references this file. Load once per session.
>
> **Loading convention**:
> - **First activation / resume / context recovery** → read this entire file
> - **Chained dispatch (same session, base already in context)** → read only `## Compact Summary` (lines 1–30)

---

## Compact Summary

<!-- For chained skill dispatch within the same session. Covers essentials only. -->

- **Platform**: detect `.kiro/` → `.claude/` → `.cursor/` → `.windsurf/`. Paths: `SPECS_DIR` = `.aidlc/specs`, `WORKFLOW_DIR` = `.aidlc/workflow`, `STEERING_DIR` = platform-dependent (`steering` or `rules`), `SKILL_DIR` = `{PLATFORM_DIR}/skills/aidlc-{current-skill}`
- **Feature**: scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml` → one=use it, many=ask, none=infer from `{SPECS_DIR}/` or ask
- **Manifest**: silent read/write at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`. On approval: set `status: "approved"`, add to `sharedPhases`
- **Language**: ALL output in user's language (manifest `language` field). English only for: paths, code, YAML keys, skill/command names, tech terms. Translate templates before presenting. No mixing.
- **Silent ops**: never narrate file reads, manifest writes, path resolution, template loading, scope detection
- **Status header**: `📍 {Phase} | {Stage} | ✅ {Completed}` — top of every user-facing response (skip for errors/help)
- **Audit**: append to `{WORKFLOW_DIR}/{feature}/audit.md` — format: `### [{ISO}] {Phase}: {Action}` with Phase/Action/Artifacts/Outcome fields
- **Decision gates**: generate blank answers → present → STOP → validate conflicts → resolve → store in manifest. Never auto-fill.
- **Output paths**: comprehensive = `{SPECS_DIR}/{feature}/`, incremental = `{SPECS_DIR}/{feature}/units/{unit}/`. Never mix.
- **Handoff**: read `{PLATFORM_DIR}/skills/aidlc-{next}/SKILL.md` → follow its instructions. Transparent to user.
- **Tools**: Kiro=`fsWrite`,`readMultipleFiles`,`readCode`. Claude Code=`Write`/`Edit`,parallel `Read`. Cursor/Windsurf=sequential.
- **Errors**: report clearly, offer rebuild/retry, never lose work silently. Missing optional files=skip silently.

---

## Full Reference

### Environment Detection

| Check | Platform | STEERING_DIR | SKILL_DIR base |
|---|---|---|---|
| `.kiro/` exists | Kiro | `.kiro/steering` | `.kiro/skills/` |
| `.claude/` exists | Claude Code | `.claude/rules` | `.claude/skills/` |
| `.cursor/` exists | Cursor | `.cursor/rules` | `.cursor/skills/` |
| `.windsurf/` exists | Windsurf | `.windsurf/rules` | `.windsurf/skills/` |

Derived: `SPECS_DIR` = `.aidlc/specs`, `WORKFLOW_DIR` = `.aidlc/workflow`, `ASSETS_DIR` = `{SKILL_DIR}/assets`, `REFERENCES_DIR` = `{SKILL_DIR}/references`

### Feature Name Resolution

1. Scan `{WORKFLOW_DIR}/*/aidlc-manifest.yaml`
2. One manifest → use its `feature` field
3. Multiple → ask user
4. None → infer from `{SPECS_DIR}/` folders, or ask

### Manifest Operations

- **Path**: `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` — silent, never narrate
- **On approval**: `artifacts.{phase}.status: "approved"`, `artifacts.{phase}.timestamp: "{ISO}"`, add phase to `state.sharedPhases`
- **Downstream outdated**: when artifact edited post-approval, mark all later phases `status: "outdated"`. Order: context → requirements → decomposition → design → tasks → implement → build → deploy. Only active phases for current scope (see `scopes.md`).
- **Incremental mode**: unit artifacts at `{SPECS_DIR}/{feature}/units/{unit}/`, unit workflow at `{WORKFLOW_DIR}/{feature}/units/{unit}/`, manifest entries at `units[name={unit}].artifacts.{phase}`

### Language Rule

ALL output in user's language (from manifest `language` field). Translate all template text before presenting.

**English only**: file paths, skill/phase/command names, tech terms (REST, API, JWT), code, YAML keys, manifest values.

**Artifacts**: narrative content in user's language. English for IDs (US-NNN), paths, code. Steering files stay English (machine-read).

No mixing within a response or artifact file.

### Silent Operations

Never narrate: platform detection, file reads, path resolution, directory creation, manifest writes, audit entries, template/guide loading, scope detection. If intermediate text is required, it must be in user's language.

### Status Header

Top of every user-facing response (decision gates, generation results, approvals, transitions):

```
📍 {AIDLC Phase} | {Current Stage} | ✅ {Completed Stages}
```

- Phase: `Inception` (context/requirements/decomposition), `Construction` (design/tasks/implement), `Operation` (build/deploy)
- Completed: short names from `state.sharedPhases` — `ctx`, `req`, `decomp`, `design`, `tasks`, `impl`, `build`, `deploy`. Incremental: `auth(impl)`, `payments(design)`

Skip for error messages and help/status commands.

### Context Recovery

1. Read `{STEERING_DIR}/aidlc-workflow.md` → manifest path
2. Read manifest → current phase, artifacts, decisions
3. Activate orchestrator (`{PLATFORM_DIR}/skills/aidlc/SKILL.md`), execute `resume`
4. Orchestrator re-reads current skill's SKILL.md, loads action files, re-reads templates/references from disk. Never generate from memory.

### Audit Trail

Append to `{WORKFLOW_DIR}/{feature}/audit.md` after significant actions:

```
### [{ISO timestamp}] {Phase}: {Action}

**Phase**: {phase-name}
**Action**: {action-type}
**Artifacts**: {files created or modified}
**Outcome**: {result summary}
```

### Skill Handoff

1. Resolve: `{PLATFORM_DIR}/skills/aidlc-{next-skill}/SKILL.md`
2. Read and follow its instructions — transition is transparent to user
3. If not found: `👉 Next: Activate the **aidlc-{next-skill}** skill to continue.`

**Loading convention for chained dispatch**: If base.md is already in context from this session, the next skill reads only the Compact Summary section. On resume or context recovery, read the full file.

### Decision Gate Protocol

Shared pattern for D1, D2, DF, D3, D4, D5:

1. Read `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md` for output structure
2. Generate with blank `Answer:` fields — **never pre-fill**
3. Present file path + "use recommendations" option. **STOP — do NOT continue.**
4. After answers: validate conflicts (per-skill rules), present grouped by severity (🔴→🟡→🟢)
5. Resolve conflicts → store compact summary in manifest `decisions.{phase}`
6. Proceed to generation

**⛔ Never auto-fill decisions.** Never proceed past step 3 without user saying "done" or "use recommendations."

### Output Path Scoping

- **Comprehensive** (or no units): `{SPECS_DIR}/{feature}/`
- **Incremental** (specific unit): `{SPECS_DIR}/{feature}/units/{unit}/`

Never write unit-scoped artifacts to the shared directory.

### Edit Action Pattern

Standard for all phase edits (design-edit, requirements-edit, etc.):

1. **Backup**: copy to `{WORKFLOW_DIR}/{feature}/history/{filename}-{ISO}.md`
2. **Apply**: read current, apply changes
3. **Re-validate**: run phase validation checks
4. **Cascade**: update all affected related artifacts
5. **Mark outdated**: downstream phases → `status: "outdated"`
6. **Learning loop**: if correction is a general rule, ask to save to `{STEERING_DIR}/corrections.md`
7. **Present**: show changes with `🔲 **Your turn**` block
8. **STOP** — wait for approval
