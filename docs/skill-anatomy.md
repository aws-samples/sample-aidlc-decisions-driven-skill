# Skill Anatomy

## Structure

Each skill follows a layered structure optimized for token efficiency:

```
aidlc-{name}/
├── SKILL.md          # Compact index — identity, activation, info contract, process table
├── actions/          # Detailed action instructions (loaded on demand, not upfront)
│   ├── decision-gate.md
│   └── generate.md
├── assets/           # Output templates (schema-style, loaded during generation)
│   ├── decision-gate.md
│   └── {output-template}.md
└── references/       # Reference material loaded conditionally
    ├── {catalog}.md
    └── {guide}.md
```

Additionally, shared patterns live inside the orchestrator:

```
aidlc/
├── SKILL.md          # Orchestrator index
├── actions/          # Orchestrator actions (routing, status, rollback, etc.)
└── shared/
    ├── base.md       # Environment detection, manifest ops, behavioral rules, audit format
    └── decision-gate.md  # Output template for all decision files
```

## Layer Descriptions

### SKILL.md

A compact index (~100-140 lines) that the orchestrator loads on dispatch. Contains:
- Identity and metadata (frontmatter)
- Activation message
- Quick start summary
- Information contract (required/optional inputs, outputs)
- Initialization steps
- Process table pointing to action files
- Skill handoff (what comes next)
- Context recovery instructions

### actions/

Detailed procedural instructions loaded only when executing that specific step — not all upfront. Each action file covers one discrete operation (decision gate generation, artifact generation, editing, etc.).

### assets/

Schema-style templates that define *what to include* in generated artifacts. The model knows markdown formatting — templates specify content structure, not visual formatting.

### references/

Supplementary material loaded conditionally — technology catalogs, validation rules, architecture guides, decomposition strategies.

### shared/base.md

Loaded once per session. Provides common operations shared across all skills:
- Environment detection (Kiro, Claude Code)
- Feature name resolution
- Manifest operations (read, update, mark outdated)
- Behavioral rules (language, status header, silent operations)
- Audit trail format
- Decision gate protocol
- Output path scoping
- Edit action pattern
- Context recovery
- Skill handoff protocol

## Extending AI-DLC

### Steering Files

Steering files in `{STEERING_DIR}/` provide persistent context across all interactions. They're created by the context skill and updated by downstream phases. You can also edit them manually to inject team standards, coding conventions, or project-specific guidance.

### Adding a New Skill

Follow the existing pattern:

1. Create `skills/aidlc-{name}/SKILL.md` with the standard structure
2. Add action files in `actions/`
3. Add asset templates in `assets/` (if the skill generates artifacts)
4. Add reference material in `references/` (if needed)
5. Update the orchestrator routing table if the skill is part of the core workflow
