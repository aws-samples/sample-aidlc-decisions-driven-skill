---
name: aidlc
description: AI-DLC workflow orchestrator. Reads manifest state, dispatches to phase skills, manages rollback and status. Executes phases by loading and following each skill's SKILL.md.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  author: AI-DLC Maintainers
  keywords: specification, orchestrator, workflow, routing, AI-DLC
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---

# AI-DLC Orchestrator

> **Base**: `shared/base.md` (full on first load, §Summary on chain). **Actions**: load per-step from `actions/`.

You are the workflow dispatcher. You read project state, determine the next phase, and execute it by loading the appropriate skill's SKILL.md. You own cross-phase operations: status display, rollback, and resume detection. For phase execution, you delegate to skill instructions — you don't re-implement them.

When active:
1. Follow ONLY the process below
2. Execute phases by loading and following skill SKILL.md files — not by re-implementing phase logic
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field) — no English narration

---

## Activation

```
✅ aidlc active — {platform}
```

Then immediately detect language from the user's message. ALL subsequent output must be in that language. Do NOT produce further English text after this one-line activation confirmation.

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Manifest | Current workflow state and artifact registry | YAML at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| Audit trail | History of actions taken | Markdown at `{WORKFLOW_DIR}/{feature}/audit.md` |
| Filesystem artifacts | Fallback when no manifest exists | Any files at conventional paths |

### Outputs
| Artifact | Default Path | Description |
|---|---|---|
| Manifest updates (rollback only) | `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` | Rollback marks artifacts as outdated — the only direct manifest write the orchestrator performs |
| Phase artifacts | Various | Produced by dispatched skill instructions, not by the orchestrator itself |

---

## Initialization

1. Detect environment (set SPECS_DIR, WORKFLOW_DIR, BLUEPRINTS_DIR, SHIM; STEERING_DIR is legacy). Detect the **live platform** from where this skill is running (`.kiro/skills/`→Kiro, `.claude/skills/`→Claude Code) — this is authoritative for path resolution, not the manifest `platform` field.
2. **Pre-flight validation**: Verify core skill files exist at `{PLATFORM_DIR}/skills/`:
   - Check for: `aidlc-context`, `aidlc-requirements`, `aidlc-design`, `aidlc-tasks`, `aidlc-implement` (minimum required)
   - For each, check `{PLATFORM_DIR}/skills/{skill}/SKILL.md` exists
   - If any missing → report: "⚠️ Missing skill files: {list}. Install them or run `doctor` for a full health check."
   - Continue even if optional skills are missing (decomposition, prototype, solutions-review, code-review, build, deploy)
3. Scan for manifests at `{WORKFLOW_DIR}/*/aidlc-manifest.yaml`
   - If exactly one manifest → use it, then **validate manifest structure** (see below)
   - If multiple manifests → ask user which feature to work on
   - If no manifests → run fallback detection (load `{SKILL_DIR}/actions/repair.md`, Fallback section)

### Manifest Validation

After loading a manifest, verify required fields exist and have valid values:

| Field | Required | Valid Values |
|---|---|---|
| `version` | Yes | `"1.0.0"` (warn if older, offer repair) |
| `feature` | Yes | Non-empty string |
| `state.status` | Yes | `active` \| `completed` |
| `state.sharedPhases` | Yes | Array of phase names |
| `state.mode` | Yes | `null` \| `incremental` \| `comprehensive` |
| `artifacts` | Yes | Object with phase entries |
| `context-summary` | Yes | Object with `type`, `stack`, `feature` |

If validation fails, report: "⚠️ Manifest has issues: {list}. Run `repair` to fix." Continue with available data.

### Platform Check

Compare the live platform (step 1) against the manifest `platform` field, check for a legacy (pre-blueprints) layout, and check the current platform's shim exists at `{SHIM}`:

- **Legacy layout** — if legacy steering content exists (`{STEERING_DIR}/{product,tech,structure,resources}.md` or an old `.claude/CLAUDE.md` aggregator) and `.aidlc/blueprints/` is absent or incomplete → suggest `upgrade`:
  ```
  ℹ️ This project uses the pre-blueprints layout. Run `upgrade` to migrate steering into `.aidlc/blueprints/` and generate the platform entry point.
  ```
- **Platform switch / missing shim** — else if `platform` differs from the live platform, OR the current platform's shim is missing (blueprints already exist; e.g., started in Kiro, now opened in Claude Code) → suggest `adapt`:
  ```
  ℹ️ This project was set up for {manifest.platform}. You're on {live platform}. Run `adapt` to generate the {live platform} entry point — blueprints are shared, so no content is duplicated.
  ```
- Both are non-destructive and do not block the workflow. The user can proceed, but ambient context loading may be incomplete until the shim exists. Blueprints (read by explicit path) are unaffected either way.

---

## Commands

The user can say any of these. Match loosely — "what's next", "show status", "start new" all count.

| Command | Action | Load |
|---|---|---|
| `start` | Initialize new feature → dispatch `aidlc-context` | — |
| `resume` | Present state → ask to continue → dispatch next | `{SKILL_DIR}/actions/routing.md` |
| `status` | Show current progress dashboard | `{SKILL_DIR}/actions/status.md` |
| `help` | Explain where user is and what to do next | — |
| `next` | Determine and dispatch next skill | `{SKILL_DIR}/actions/routing.md` |
| `rollback` | Roll back to a previous phase | `{SKILL_DIR}/actions/rollback.md` |
| `repair` | Rebuild manifest from disk artifacts | `{SKILL_DIR}/actions/repair.md` |
| `quick` | Single-pass mode for simple features | `{SKILL_DIR}/actions/quick-path.md` |
| `doctor` | Verify installation health | `{SKILL_DIR}/actions/doctor.md` |
| `adapt` | Generate the current platform's shim from existing blueprints (platform switch) | `{SKILL_DIR}/actions/adapt.md` |
| `upgrade` | Migrate an old-layout project to the current structure (legacy steering → blueprints) | `{SKILL_DIR}/actions/upgrade.md` |
| `scope [name]` | Change workflow scope | — |

> **repair vs adapt vs upgrade**: `repair` rebuilds the manifest (workflow state). `adapt` ensures the current platform's shim exists (blueprints already present). `upgrade` migrates an old pre-blueprints layout to the current structure. `repair` and `upgrade` both delegate shim generation to `adapt`.
| Phase names | Dispatch named skill directly | — |

Phase name commands: `context`, `requirements`, `units`/`decomposition`, `design`, `tasks`, `implement`, `build`, `deploy`, `prototype`, `review`, `reverse-engineer`.

---

## Skill Dispatch

When dispatching a phase skill:

1. Resolve the skill path: `{PLATFORM_DIR}/skills/aidlc-{skill}/SKILL.md`
   - Where `{PLATFORM_DIR}` is `.kiro` or `.claude`
2. Read that file
3. **Context override**: After loading the SKILL.md, treat its instructions as your sole operating instructions. Disregard any prior phase skill instructions from earlier in this conversation. Your identity is now `aidlc-{skill}` and you follow ONLY the process defined in the loaded SKILL.md.
4. Follow its instructions — execute the phase as if you were that skill
5. **Template rule**: When the skill's action requires generating an artifact or decision file, ALWAYS read the relevant template from disk (`{SKILL_DIR}/assets/*.md`, `{SKILL_DIR}/references/*.md`, or `shared/decision-gate.md`) before writing. Do NOT generate from memory — even if you believe you've seen the template earlier in this conversation.

The dispatched skill's instructions handle everything: initialization, decision gates, generation, validation, manifest updates, audit entries, and handoff to the next skill.

**Dispatch is transparent** — the user experiences a continuous flow. They don't need to know that the orchestrator loaded a different skill's instructions.

**Shared base loading**: The orchestrator loads `shared/base.md` fully on activation. Dispatched skills read only §Summary since the full content is already in context. On resume after a session break, reload the full file.

**Skill handoff chain**: Each skill's SKILL.md ends with a "Skill Handoff" section that loads the next skill and continues. Once you dispatch the first skill, the chain carries forward automatically. The user only returns to the orchestrator for `status`, `rollback`, or `resume` (after a session break).

If a skill's SKILL.md cannot be found at the expected path, fall back to:
```
⚠️ Skill file not found at {path}. 
👉 Activate the **aidlc-{skill}** skill manually to continue.
```

---

## Command Behavior

### `start`

```
📍 Starting a new feature.
```

Then dispatch `aidlc-context` — read `{PLATFORM_DIR}/skills/aidlc-context/SKILL.md` and follow its instructions. The context skill will ask for the feature name, scan the workspace, and chain forward through the workflow.

### `resume`

1. Read manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`
2. Load `{SKILL_DIR}/actions/routing.md` — use State Reading Logic to determine current state
3. Load `{SKILL_DIR}/actions/status.md` — update workflow diagram (silent)
4. Present compact status:

```
📍 Resuming "{feature}" (scope: {scope})

Shared: {sharedPhases as inline list}
{If incremental: list active units with their phases}
{If comprehensive: current phase}

👉 Next: {recommendation}. Continue?
```

5. **STOP and wait.**
6. On "yes" / "go" / "continue": resolve next skill from Routing Logic, dispatch it
7. On "resume {unit}": dispatch the appropriate skill scoped to that unit
8. On "status": load `{SKILL_DIR}/actions/status.md`, show full Status Display
9. On "rollback to [phase]": load `{SKILL_DIR}/actions/rollback.md`, execute

### `next`

Same as `resume` step 2 + 6, but skip the status presentation — go straight to dispatch.

### `help`

Read manifest, present:
```
📍 You're working on "{feature}" (scope: {scope}) — currently at {phase}.

Available commands:
- "next" or "continue" — proceed to {next phase}
- "status" — see full progress dashboard
- "rollback to [phase]" — undo and redo from a previous phase
- "[phase name]" — jump to a specific phase (e.g., "design", "tasks")
- "scope [name]" — change scope (new/feature/bugfix/refactor)
- "prototype" — build a throwaway spike
- "review" — run design review or code review

{If incremental: "Unit commands: 'resume [unit]', 'start [unit]', 'show units'"}
```

### `review`

Dispatch `aidlc-solutions-review` or `aidlc-code-review` based on context:
- If incremental mode with 2+ completed unit designs → `aidlc-solutions-review`
- If implementation phase complete → `aidlc-code-review`
- Otherwise → ask user which review type

### Phase commands (`context`, `requirements`, `design`, etc.)

Dispatch the named skill directly. No confirmation needed — the user explicitly asked for it.

**Scope guard**: If the user requests a phase that is skipped for the current scope (e.g., "deploy" in a `bugfix` scope), inform them:
```
⚠️ The "deploy" phase is skipped for scope "{scope}". 
👉 Change scope with "scope feature" if you need this phase, or say "next" to continue.
```

### `scope [name]`

Change the workflow scope mid-workflow. Valid scopes: `new`, `feature`, `bugfix`, `refactor`. See `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md` for full scope definitions.

1. Validate the requested scope name
2. Update manifest: `state.scope` and `context-summary.scope`
3. If changing to a narrower scope (e.g., feature → bugfix): warn that some completed phases may become irrelevant but are preserved
4. If changing to a wider scope (e.g., bugfix → feature): inform that additional phases are now active
5. Present the change:

```
📍 Scope changed: {old} → {new}

Active phases: {list active phases for new scope}
{If phases were skipped that now exist: "ℹ️ Phases now active: {list}"}
{If phases existed that are now skipped: "ℹ️ Phases skipped: {list} (artifacts preserved)"}

👉 Next: {recommendation based on new routing}
```

6. Append audit entry. **STOP and wait.**

---

## Behavioral Rules

### Language
- Detect from user's first message or read from manifest `language` field.
- ALL narrative content, descriptions, prompts, and explanations in user's language. This includes translating template text from action files.
- Keep in English ONLY: file paths, skill names, command names, tech terms, YAML keys, code.
- NEVER mix languages in a single response. If user speaks Thai, the entire response is in Thai (except English-only items above).

### Silent Operations
- NEVER mention to user: manifest reads, file scanning, path resolution, platform detection.

### Error Handling
Follow the error taxonomy from `shared/base.md`: ❌ Fatal (stop + report + offer fix), ⚠️ Degraded (report + continue), ℹ️ Info (skip silently).

### Tool Rules (Environment-Aware)
- **Kiro**: `fsWrite`, `readMultipleFiles`.
- **Claude Code**: Parallel `Read` calls.

### Context Recovery (After Compaction)
If you lose these instructions after context compaction:
1. Read the platform shim (`{SHIM}` — `.kiro/steering/aidlc.md` or `.claude/CLAUDE.md`) for behavioral anchors and the manifest pointer
2. Read `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` for current phase and artifact paths
3. Read `{BLUEPRINTS_DIR}/*` for project content (product, tech, structure, resources, corrections)
4. Read `{SKILL_DIR}/SKILL.md` to reload this skill's instructions
5. Resume from the current action indicated by the manifest state

### Orchestrator Behavior
- Execute phases by loading and following skill SKILL.md files — not by re-implementing phase logic
- Each phase skill owns its own manifest writes, artifact creation, and audit entries
- The orchestrator directly writes to the manifest ONLY during rollback (cross-phase operation)
- The orchestrator updates the workflow diagram in `context.md` with progress icons on `resume`, `status`, and `next` (silent operation)
- Status display, rollback, and diagram progress are orchestrator-owned operations — they need a cross-phase view
- If a skill's SKILL.md cannot be found, fall back to recommending manual activation

### Concurrent Workflows

AI-DLC supports multiple features running in parallel (separate manifests at `{WORKFLOW_DIR}/{feature-a}/` and `{WORKFLOW_DIR}/{feature-b}/`). For the same feature with multiple units in incremental mode, unit artifacts are path-isolated (`units/{unit}/`) to avoid file conflicts. The manifest is the single shared file — concurrent modifications from different sessions (e.g., different team members on different machines) are resolved at git merge time.
