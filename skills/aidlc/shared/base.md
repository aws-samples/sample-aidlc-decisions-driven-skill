# AI-DLC Shared Base

> Load once per session (full file). On chained dispatch within same session, re-read only §Summary.

---

## Summary

- **Platform**: `.kiro/`→Kiro, `.claude/`→Claude Code
- **Paths**: SPECS=`.aidlc/specs`, WORKFLOW=`.aidlc/workflow`, BLUEPRINTS=`.aidlc/blueprints` (canonical steering content — platform-agnostic), SHIM=Kiro:`.kiro/steering/aidlc.md`|Claude:`.claude/CLAUDE.md` (thin per-platform entry point → references blueprints), STEERING=Kiro:`.kiro/steering`|Claude:`.claude/rules` (legacy dir; content migrating to BLUEPRINTS), SKILL_DIR=`{PLATFORM}/skills/aidlc-{skill}`, ASSETS=`{SKILL_DIR}/assets`, REFS=`{SKILL_DIR}/references`
- **Blueprints**: product/tech/structure/resources/corrections are canonical at `{BLUEPRINTS}/` (no platform front-matter). The platform SHIM carries behavioral anchors inline + references blueprints (Kiro `#[[file:.aidlc/blueprints/*.md]]`, Claude `@../.aidlc/blueprints/*.md`). Skills read blueprints by explicit path; the shim serves ambient sessions.
- **Feature**: scan `{WORKFLOW}/*/aidlc-manifest.yaml` → one=use, many=ask, none=infer or ask
- **Manifest**: silent read/write. On approval: `status:"approved"`, add to `sharedPhases`. Downstream outdated: mark all later phases. Order: context→requirements→decomposition→design→tasks→implement→build→deploy.
- **Language**: ALL output in user's language (manifest `language`). English only: paths, code, YAML keys, tech terms, skill names. Translate templates. No mixing.
- **Silent**: never narrate reads, writes, detection, resolution, template loading, scope detection.
- **Status header**: `📍 {Phase} | {Stage} | ✅ {Completed}` — every user-facing response (skip for errors/help).
- **Audit**: append `### [{ISO}] {Phase}: {Action}` + Phase/Action/Artifacts/Outcome to `{WORKFLOW}/{feature}/audit.md`.
- **Decisions**: blank answers → present → **STOP** → validate → resolve → store. ⛔ Never auto-fill. Never continue without "done"/"use recommendations".
- **Output paths**: comprehensive=`{SPECS}/{feature}/`, incremental=`{SPECS}/{feature}/units/{unit}/`. Never mix.
- **Handoff**: read `{PLATFORM}/skills/aidlc-{next}/SKILL.md` → follow as sole instructions. Transparent to user.
- **Tools**: Kiro=`fsWrite`,`readMultipleFiles`,`readCode`. Claude=`Write`/`Edit`,parallel `Read`.
- **Errors**: ❌ Fatal (stop+report+offer fix) | ⚠️ Degraded (report+continue) | ℹ️ Info (skip). Never lose work.
- **Every `🔲 Your turn` block is a hard stop.** Do not continue past it.

---

## Incremental Mode Paths

- Unit artifacts: `{SPECS}/{feature}/units/{unit}/`
- Unit workflow: `{WORKFLOW}/{feature}/units/{unit}/`
- Manifest entries: `units[name={unit}].artifacts.{phase}`
- Never write unit-scoped artifacts to the shared feature directory.

---

## Status Header Details

```
📍 {AIDLC Phase} | {Current Stage} | ✅ {Completed}
```

- Phase grouping: Inception (context/requirements/decomposition), Construction (design/tasks/implement), Operation (build/deploy)
- Completed shortnames: `ctx`, `req`, `decomp`, `design`, `tasks`, `impl`, `build`, `deploy`. Incremental: `auth(impl)`, `payments(design)`

---

## Error Protocol

| Level | When | Action |
|---|---|---|
| ❌ Fatal | Missing required input, corrupt manifest | `❌ {What}\n👉 {Fix}` — stop |
| ⚠️ Degraded | Missing optional, stale artifact | Report briefly, continue |
| ℹ️ Info | Optional file absent, skipped phase | Skip silently |

Rules: missing optional files=silent. Unreadable file=⚠️. Required missing=❌. Write failure=report immediately.

---

## Decision Gate Protocol

Shared pattern for all gates (D1–D5):
1. Read `shared/decision-gate.md` for output structure
2. Generate with blank `Answer:` — never pre-fill
3. Present path + "use recommendations" option. **STOP.**
4. After answers: validate conflicts (per-skill rules), present by severity 🔴→🟡→🟢
5. Resolve → store in manifest `decisions.{phase}` → proceed to generation

---

## Edit Action Pattern

Standard for all phase edits:
1. Backup → `{WORKFLOW}/{feature}/history/{file}-{ISO}.md`
2. Apply changes
3. Re-validate (phase checks)
4. Cascade to related artifacts
5. Mark downstream `status:"outdated"`
6. Learning loop: if correction is a general rule → ask to save to `{BLUEPRINTS}/corrections.md`
7. Present with `🔲 Your turn` block
8. **STOP**

---

## Context Recovery

1. Read the platform shim (`{SHIM}`) → behavioral anchors + manifest pointer
2. Read manifest → phase, artifacts, decisions
3. Read `{BLUEPRINTS}/*` for project content (product, tech, structure, resources, corrections)
4. Read current skill's SKILL.md → reload instructions
5. Resume from current action. Never generate from memory — always re-read templates from disk.

---

## Skill Handoff

1. Resolve `{PLATFORM}/skills/aidlc-{next}/SKILL.md`
2. Read it — treat as sole operating instructions (disregard prior skill's rules)
3. If not found: `👉 Activate **aidlc-{next}** to continue.`

On chained dispatch: next skill reads only §Summary of this file.
On resume/recovery: read full file.
