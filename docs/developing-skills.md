# Developing a New Skill

This guide walks you through creating a new AI-DLC skill from scratch.

## When to Create a New Skill

Create a new skill when:
- You need a new **workflow phase** (rare — most contributions extend existing phases)
- You need a new **supporting tool** (e.g., `aidlc-migration`, `aidlc-performance-test`)
- The behavior is distinct enough that it shouldn't be an action within an existing skill

Don't create a new skill when:
- You're adding a new decision gate question → extend the existing skill's `decision-gate.md`
- You're adding a new output format → add a template to the existing skill's `assets/`
- You're adding reference material → add to the existing skill's `references/`

## Directory Structure

```
skills/aidlc-{name}/
├── SKILL.md              # Required — compact index
├── actions/              # Required — step-by-step instructions
│   ├── {action-1}.md
│   └── {action-2}.md
├── assets/               # Optional — output templates
│   └── {template}.md
└── references/           # Optional — catalogs, guides
    └── {reference}.md
```

## Step 1: Create SKILL.md

The SKILL.md is the entry point. It must contain:

### Frontmatter (YAML)

```yaml
---
name: aidlc-{name}
description: One sentence describing what this skill does.
license: MIT
compatibility: Requires file system access. Auto-detects environment.
metadata:
  version: 1.0.0
  author: AI-DLC Maintainers
  keywords: [specification, {your-keywords}, AI-DLC]
  supported_platforms:
    - kiro-ide
    - kiro-cli
    - claude-code
---
```

### Required Sections

```markdown
# {Skill Name} Skill

> **Base**: `shared/base.md` (full on first load, §Summary on chain). **Actions**: load per-step from `actions/`.

[One paragraph describing what this skill does and its personality/approach]

When active:
1. Follow ONLY the process below
2. WAIT for user approval at each checkpoint
3. Never narrate your internal process
4. ALL output in the user's language (read manifest `language` field)

---

## Activation

```
✅ aidlc-{name} v1.0.0 active — {platform} detected.
[Ready message]
```

---

## Quick Start

[3-5 bullet numbered list of the high-level flow]

**Reads**: [what inputs this skill needs]
**Writes**: [what outputs this skill produces]

---

## Information Contract

### Required Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| ... | ... | ... |

### Optional Inputs
| Information | Description | Accepted Formats |
|---|---|---|
| ... | ... | ... |

### Outputs
| Artifact | Default Path |
|---|---|
| ... | ... |

---

## Initialization

[Numbered steps for setup — environment detection, feature resolution, manifest reading]

---

## Process

Execute actions sequentially. **Load the action file when you reach that step — not before.**

| Step | Action | Load |
|---|---|---|
| 1 | ... | `{SKILL_DIR}/actions/{action-1}.md` |
| 2 | ... | `{SKILL_DIR}/actions/{action-2}.md` |

---

## Skill Handoff

**Next skill**: `aidlc-{next}` (on user approval).

---

## Phase-Specific Rules

[Any rules unique to this skill]

---

## Context Recovery

If context is lost mid-phase, follow `aidlc/shared/base.md` Context Recovery, then:
[Skill-specific recovery logic based on manifest state]
```

## Step 2: Create Action Files

Each action file in `actions/` covers one discrete step. Keep them focused:

- **One action = one user interaction** (generate something, present, wait for approval)
- Use algorithmic format over prose — dense step lists, tables, conditions
- Always end user-facing steps with `🔲 **Your turn**` block + **STOP**
- Reference templates from `{ASSETS_DIR}/` and guides from `{REFERENCES_DIR}/`

### Action File Pattern

```markdown
# Action: {action-name}

## [Step or section name]

[Instructions — numbered steps, tables, conditions]

## Present Results

```
📍 {Phase}

[Summary]

---
🔲 **Your turn**:
- ✅ "approve" — proceed
- ✏️ "change [what]" — request edits
```

**STOP and wait.**

## Update Manifest

[What to write to the manifest after this action completes]
```

## Step 3: Create Asset Templates (if applicable)

Asset templates define the **structure** of generated artifacts — not the formatting (the model handles markdown formatting). Use schema-style descriptions:

```markdown
# {Output Name} — Output Template

**Path**: `{SPECS_DIR}/{feature}/{output-file}.md`

## Structure

```yaml
sections:
  summary:
    - field_1: description
    - field_2: description
  details:
    - section_1: what goes here
    - section_2: what goes here
```

## Rules

- [Constraints on what to include/exclude]
- [Cross-references to other design files]
- [Conditional sections]
```

## Step 4: Create Reference Files (if applicable)

References provide domain knowledge loaded conditionally. They should be:
- **Stack-aware** — organized by language/framework so only relevant sections are loaded
- **Evergreen** — describe patterns, not pinned versions (versions are resolved at generation time)
- **Selective** — include a header comment explaining when to load this file

```markdown
# {Topic} — Reference

<!-- last_verified: YYYY-MM-DD -->

> **Usage**: Load when [condition]. Read ONLY the section matching [context].

## Section: Node.js / TypeScript
[patterns for this stack]

## Section: Python
[patterns for this stack]
```

## Step 5: Register in the Orchestrator (if workflow phase)

If your skill is a new workflow phase (not just a supporting tool):

1. Add to the routing table in `skills/aidlc/actions/routing.md`
2. Add to the phase order in `skills/aidlc/shared/scopes.md` (decide which scopes include it)
3. Add to the doctor check in `skills/aidlc/actions/doctor.md`
4. Update `docs/skills-reference.md`
5. Update `docs/artifacts.md` with new outputs

If it's a supporting skill (invoked on demand, not part of the phase chain):
- Add to doctor's optional skills list
- Update `docs/skills-reference.md` Supporting Skills table

## Step 6: Validate

Run the validation script to verify all cross-references:

```bash
./scripts/validate.sh
```

## Step 7: Test

Test your skill by:
1. Install skills into a test project: `cp -r skills/aidlc* /tmp/test-project/.kiro/skills/`
2. Activate the skill directly (without orchestrator): tell the AI "activate aidlc-{name}"
3. Verify it resolves inputs, generates outputs, updates manifest correctly
4. Test context recovery: mid-phase, start a new session and say "resume"

## Checklist

Before submitting a PR for a new skill:

- [ ] `SKILL.md` has valid frontmatter (name, description, version)
- [ ] All action files referenced in the Process table exist
- [ ] All asset files referenced in action files exist
- [ ] All reference files referenced in action files exist
- [ ] `./scripts/validate.sh` passes
- [ ] Skill works standalone (without orchestrator)
- [ ] Skill works via orchestrator dispatch
- [ ] Context recovery works (resume after session break)
- [ ] Manifest is updated correctly after each action
- [ ] Audit entries are appended correctly
- [ ] Output is in user's language (not hardcoded English)
