# Action: context-assessment

## Step 1: Workspace Detection

Scan the workspace:
- Check for existing source files (.ts, .js, .py, .java, etc.)
- Check for build configuration (package.json, pom.xml, Cargo.toml, etc.)
- Classify as **Greenfield** or **Brownfield**

## Step 2: Technology Stack Detection (Brownfield)

If brownfield, identify:
- **Stack**: Languages, Frameworks, Build System, Testing, Infrastructure
- **Patterns & Conventions**: Architecture pattern, data access, API response format, error handling, auth, validation, logging. Detect from source code, not just config files.
- **Environment**: Config approach, environments, secrets management
- **CI/CD**: Pipeline tool, stages, deploy target
- **Dependencies**: Lockfile, version strategy, monorepo tooling
- **Technical Debt**: Deprecated patterns, low coverage areas, known issues

## Step 3: Existing Code Analysis (Brownfield)

Document:
- **Architecture pattern**: How modules are organized and depend on each other
- **Entry points**: API servers, workers, CLI commands — what they do
- **Data layer**: Database types, ORMs, access patterns
- **Key components**: Important modules and their responsibilities
- **Integration points**: External APIs, databases, services
- **Module dependencies**: Import graph
- **Data flow**: Request lifecycle (middleware → handler → service → repository → database)
- **Key abstractions**: Base classes, interfaces, patterns
- **Test organization**: Where tests live, types, coverage, utilities
- **Build artifacts**: What gets built, containerization, deploy target

## Step 4: Feature Impact Assessment

Assess: Affected areas, Files likely to change, Dependencies.

## Step 5: Scope Detection

Determine the workflow scope from the user's request and workspace analysis. The scope controls which phases are relevant.

> **Source of truth**: Read `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md` for full detection rules, phase mappings, and diagram templates.

### Detection Rules

Analyze the user's feature description and workspace context. Refer to scopes.md Detection Rules table for keyword signals per scope.

| Scope | Detect When |
|---|---|
| `new` | No existing source code, OR building from scratch, OR rewriting |
| `bugfix` | Fixing a specific bug or error |
| `refactor` | Restructuring without changing behavior |
| `feature` | Everything else — adding new capability to existing code |

**Ambiguity rule**: If detection is ambiguous, default to `feature` and let the user override.

**Rewrite detection**: If the user says "rewrite" or "rebuild" and an existing codebase exists (brownfield workspace), set scope to `new` and recommend running `reverse-engineer` first to capture existing behavior before requirements. Present:
```
📍 Detected: application rewrite (scope: new)
💡 Recommend running "reverse-engineer" first to capture existing business rules, integrations, and patterns before starting requirements.
```

### Scope Confirmation

After detecting scope, present it to the user in the results (Step 10). The user can override by saying "change scope to [X]".

## Step 6: Generate Context

Read `{ASSETS_DIR}/context.md` for output structure.
Generate `{SPECS_DIR}/{feature}/context.md`.

## Step 7: Generate Blueprints and Platform Shim

Project content is canonical and platform-agnostic — write it once to `{BLUEPRINTS_DIR}/` (`.aidlc/blueprints/`). The platform shim references it, so a project moves between Kiro and Claude Code without duplicating or re-syncing content.

### 7a. Generate blueprint content files (no front-matter)

Read each asset template and generate the corresponding blueprint:

1. `{ASSETS_DIR}/steering-product.md` → `{BLUEPRINTS_DIR}/product.md`
2. `{ASSETS_DIR}/steering-tech.md` → `{BLUEPRINTS_DIR}/tech.md`
3. `{ASSETS_DIR}/steering-structure.md` → `{BLUEPRINTS_DIR}/structure.md`
4. `{ASSETS_DIR}/steering-resources.md` → `{BLUEPRINTS_DIR}/resources.md`

Do NOT create `corrections.md` here — it is created on-demand by the learning loop (see `steering-corrections.md`).

**Greenfield**: Populate `product.md` from the user's request. Use "Pending D3 decisions" placeholders in `tech.md` and `structure.md`.
**Brownfield**: Populate all files with detected stack, structure, and conventions.
**If a blueprint already exists**: Read it fully. Do NOT overwrite or discard existing content:
  - **Preserve** settled decisions, detected stack, conventions, content from other phases.
  - **Update** the feature-specific section (Summary, current feature description).
  - **Append** new information alongside existing content.
  - **`resources.md`** — merge: keep existing, add new.

### 7b. Generate the platform shim

Generate the thin entry point for the **detected platform**. The shim is static and project-level (it carries behavioral anchors + blueprint references, no feature state) — overwriting is safe since it holds no project content.

- **Kiro**: `{ASSETS_DIR}/steering-workflow.md` → `.kiro/steering/aidlc.md` (`inclusion: always` front-matter; `#[[file:.aidlc/blueprints/*.md]]` references)
- **Claude Code**: `{ASSETS_DIR}/claude-md.md` → `.claude/CLAUDE.md` (`@../.aidlc/blueprints/*.md` imports)

Generate only the detected platform's shim. (The `adapt` flow generates the other platform's shim when a project moves between platforms.)

## Step 8: Update Manifest

Update the skeleton manifest at `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml` with full context from the assessment:

```yaml
# Update these fields (skeleton already has version, feature, language, platform, created, state.status):
updated: "{ISO timestamp}"
state:
  scope: "{detected scope from Step 5}"
artifacts:
  context:
    status: "draft"
    timestamp: "{ISO timestamp}"
    files: [context.md]
context-summary:
  type: "{Greenfield/Brownfield}"
  scope: "{feature/bugfix/refactor/new}"
  stack: "{Primary language + framework}"
  architecture: "{Pattern}"
  feature: "{1-sentence description}"
  impact: "{New standalone / Extends existing / Cross-cutting}"
  complexity: "{Low/Medium/High}"
  teamSize: null
  recommendations: { personas: false, units: false, nfr: false }
steering:
  updatedBy:
    product: [context]
    tech: [context]
    structure: [context]
```

## Step 9: Validate

- ✅ Project type identified (greenfield/brownfield)
- ✅ Scope detected and stored in manifest
- ✅ Technology stack documented (if brownfield)
- ✅ Architecture pattern identified (if brownfield)
- ✅ Feature impact assessment complete
- ✅ Recommendations provided (Personas, Units, NFR)
- ✅ Blueprints generated (product, tech, structure, resources) at `{BLUEPRINTS_DIR}/`
- ✅ Platform shim generated for the detected platform (`.kiro/steering/aidlc.md` or `.claude/CLAUDE.md`)
- ✅ Manifest updated with full context-summary

## Step 10: Present Results

```
📍 Context Assessment

[Summary of findings]

- **Project Type**: [Greenfield/Brownfield]
- **Scope**: [new/feature/bugfix/refactor]
- **Stack**: [Detected or N/A]
- **Architecture**: [Detected or N/A]
- **Impact**: [New standalone / Extends existing / Cross-cutting]
- **Recommendations**: Personas [Yes/No], Units [Yes/No], NFR [Yes/No]

## Recommended Workflow

[ASCII workflow diagram — tailored to scope and project complexity]

Artifact at `{SPECS_DIR}/{feature}/context.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to requirements
- ✏️ "change [what]" — request edits
- 🔀 "change scope to [bugfix/refactor/feature/new]" — override detected scope
```

**Generate workflow diagram** based on scope and recommendations. Use top-down ASCII art. Show ONLY the recommended path for this project.

Diagram templates by scope — see `{PLATFORM_DIR}/skills/aidlc/shared/scopes.md` § Workflow Diagram Templates for the full list.

**STOP and wait for user approval.**

On approval: update manifest (`artifacts.context.status` → `"approved"`, add `"context"` to `state.sharedPhases`). Append audit entry. Then auto-continue to requirements.
