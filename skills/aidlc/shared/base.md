# AI-DLC Shared Base

> **Usage**: Every phase skill references this file for common operations. Load once per session — do not re-read if already in context. Phase-specific SKILL.md files extend (never override) these shared behaviors.

---

## Environment Detection

Detect platform and set path variables:

| Check | Platform | STEERING_DIR | SKILL_DIR base |
|---|---|---|---|
| `.kiro/` exists | Kiro | `.kiro/steering` | `.kiro/skills/` |
| `.claude/` exists | Claude Code | `.claude/rules` | `.claude/skills/` |
| `.cursor/` exists | Cursor | `.cursor/rules` | `.cursor/skills/` |
| `.windsurf/` exists | Windsurf | `.windsurf/rules` | `.windsurf/skills/` |

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

Phase order: context → requirements → decomposition → design → tasks → implement → build → deploy

### Scope-Aware Phase Order

> **Source of truth**: Load `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md` for the full scope definitions, phase mappings, and decision gate behavior per scope. The table below is a summary — if in doubt, read scopes.md.

The full phase order applies to `new` and `feature` scopes. Other scopes skip phases — see `shared/scopes.md` for the authoritative mapping. Skipped phases do not appear in `state.sharedPhases` — they are absent from the workflow entirely. Downstream outdated marking only applies to phases that are active for the current scope.

### Unit-Scoped Operations (Incremental Mode)
- Unit artifacts: `{SPECS_DIR}/{feature}/units/{unit}/`
- Unit workflow: `{WORKFLOW_DIR}/{feature}/units/{unit}/`
- Unit manifest entries: `units[name={unit}].artifacts.{phase}`

---

## Behavioral Rules

### ⛔ Language — HARD RULE

**Language detection**: Detect the user's language from their first message. Store in manifest as `language` field (ISO 639-1 code). Once detected, ALL subsequent responses MUST use that language.

**⛔ ZERO TOLERANCE**: Every piece of text you produce — including progress messages, acknowledgments, and intermediate output between tool calls — MUST be in the user's language. If you catch yourself writing English narrative text in a non-English session, STOP and rewrite it. There are NO exceptions for "thinking aloud" or "explaining what you're doing next."

**What MUST be in the user's language**:
- All explanations, descriptions, instructions, and narrative text
- Progress messages between tool calls (if you produce any at all)
- Section headers and labels in responses (e.g., "Your turn" → translated equivalent)
- Decision gate questions and descriptions
- Status messages and progress updates
- Error messages and suggestions
- Approval prompts and option descriptions

**What MUST stay in English**:
- File paths and directory names (`{SPECS_DIR}/{feature}/design.md`)
- Skill names and phase names (`aidlc-design`, `D3`)
- Technical terms that have no standard translation (REST, API, JWT, CI/CD)
- Code snippets, variable names, YAML keys
- Manifest field names and values
- Command names (`start`, `resume`, `status`, `rollback`)

**Template translation rule**: Action files contain English template strings (e.g., "📍 Tasks Complete — Choose Implementation Mode"). These are structural guides, NOT literal output. Translate all human-readable text in templates to the user's language before presenting. Only keep the structural markers (📍, 🔲, ✅, ✏️, etc.) and English-only items listed above.

**⛔ Artifact language rule**: Generated artifact files (context.md, requirements.md, personas.md, decisions-*.md, design.md, design/*.md, units.md, tasks.md, build-report.md, deploy-summary.md) MUST have their narrative content written in the user's language. Asset templates are English-language structural guides — translate all human-readable content when writing the actual artifact file. Only these stay in English inside artifact files:
- YAML keys, IDs (US-NNN), file paths, code snippets
- Technical terms (REST, API, JWT, CI/CD)
- Section heading markers that are referenced by other skills (e.g., `## Summary`, `## Decisions Summary`)
- Steering files (`product.md`, `tech.md`, `structure.md`, `aidlc-workflow.md`) — these are machine-read by skills and stay English

**Consistency rule**: Do NOT mix languages within a single response OR within a single artifact file. If the user's language is Thai, ALL narrative text in both chat and files must be in Thai.

### ⛔ Silent Operations — HARD RULE

Do NOT produce text between tool calls unless it is a user-facing result. The following are NEVER narrated to the user:
- Platform detection, environment setup
- File reads (manifest, steering, templates, assets, references, scopes)
- Path resolution, directory creation
- Manifest writes, audit entries
- Template loading, guide loading
- Scope detection logic

If you MUST produce intermediate text (e.g., the platform requires acknowledgment), it MUST be in the user's detected language — NEVER in English.

### Status Header
Include a status line at the top of every user-facing response (decision gates, generation results, approval prompts, phase transitions). Derive from manifest state:

```
📍 {AIDLC Phase} | {Current Stage} | ✅ {Completed Stages}
```

**AIDLC Phase** derivation:
- `Inception` — if current work is context, requirements, or decomposition
- `Construction` — if current work is design, tasks, or implement (including per-unit)
- `Operation` — if current work is build or deploy

**Current Stage**: the active skill/action (e.g., "Design — D3 Decision Gate", "Implement — Task 3.2", "Build — Quality Gates")

**Completed Stages**: compact list from `state.sharedPhases` + unit progress. Use short names: `ctx`, `req`, `decomp`, `design`, `tasks`, `impl`, `build`, `deploy`. For incremental mode, append unit context: `auth(impl)`, `payments(design)`.

Examples:
- `📍 Inception | Requirements — D1 Decision Gate | ✅ ctx`
- `📍 Construction | Design — Generation | ✅ ctx, req, decomp`
- `📍 Construction | Implement — Task 2.1 [auth] | ✅ ctx, req, decomp, auth(design, tasks)`
- `📍 Operation | Build — Quality Gates | ✅ ctx, req, decomp, auth(impl), payments(impl)`

Skip this header only for error messages and help/status commands (which have their own format).

### Tool Preferences by Platform
- **Kiro**: `fsWrite`, `readMultipleFiles`, `readCode`
- **Claude Code**: `Write`/`Edit`, parallel `Read`
- **Cursor/Windsurf**: `Write`/`Edit`, sequential reads

### Context Recovery
If context is lost mid-phase:
1. Read `{STEERING_DIR}/aidlc-workflow.md` → get manifest path and current state
2. Read manifest → get current phase, artifact paths, decisions
3. Activate the **aidlc** orchestrator skill (`{PLATFORM_DIR}/skills/aidlc/SKILL.md`) and execute `resume` — this ensures proper routing, scope checks, unit dashboard, and template re-reading
4. The orchestrator will re-read the current skill's SKILL.md, load the correct action file, and **re-read all templates and references** (`{SKILL_DIR}/assets/*.md`, `{SKILL_DIR}/references/*.md`, `{PLATFORM_DIR}/skills/aidlc/shared/decision-gate.md`) before doing any work. Do NOT generate from memory — always read from disk.

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

**NEVER write unit-scoped artifacts to the shared `{SPECS_DIR}/{feature}/` directory.** Shared directory is reserved for project-wide artifacts (context.md, requirements.md, units.md).

---

## Edit Action Pattern

Standard pattern for all phase artifact edits (design-edit, requirements-edit, foundation-edit, etc.):

1. **Backup**: Copy files being modified to `{WORKFLOW_DIR}/{feature}/history/{filename}-{ISO-timestamp}.md`
2. **Apply**: Read current artifact, apply requested changes
3. **Re-validate**: Run the phase's validation checks (defined per-skill)
4. **Cascade**: If change affects related files, update ALL affected artifacts (e.g., renaming an entity cascades to data-model, api-spec, components)
5. **Mark outdated**: Set all downstream phase artifacts to `status: "outdated"` in manifest
6. **Learning loop**: If the user's correction represents a **general rule** (not just a one-off fix for this feature), ask:
   ```
   💡 Should I remember this for future workflows?
   (e.g., "always use X", "never do Y", "prefer Z pattern")
   - ✅ "yes" — I'll add it to project corrections
   - ⏭️ "no" — one-time change only
   ```
   If "yes": append the rule to `{STEERING_DIR}/corrections.md` (create if doesn't exist). Use the format defined in the corrections template. **Kiro only**: ensure `inclusion: always` front-matter exists.
7. **Present**: Show what changed with `🔲 **Your turn**` block
8. **STOP** — wait for approval
