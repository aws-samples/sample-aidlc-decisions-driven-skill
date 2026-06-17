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

## Step 5: Generate Context

Read `{ASSETS_DIR}/context.md` for output structure.
Generate `{SPECS_DIR}/{feature}/context.md`.

## Step 6: Generate Steering Files

Read each asset template and generate the corresponding steering file:

1. `{ASSETS_DIR}/steering-product.md` → `{STEERING_DIR}/product.md`
2. `{ASSETS_DIR}/steering-tech.md` → `{STEERING_DIR}/tech.md`
3. `{ASSETS_DIR}/steering-structure.md` → `{STEERING_DIR}/structure.md`
4. `{ASSETS_DIR}/steering-workflow.md` → `{STEERING_DIR}/aidlc-workflow.md`
5. `{ASSETS_DIR}/steering-resources.md` → `{STEERING_DIR}/resources.md`

**Kiro only**: Add `inclusion: always` YAML front-matter to each steering file.
**Claude Code only**: Also generate `.claude/CLAUDE.md` using `{ASSETS_DIR}/claude-md.md`.
**Cursor/Windsurf**: No front-matter, no CLAUDE.md.

**Greenfield**: Populate `product.md` from user's request. Use "Pending D3 decisions" placeholders in `tech.md` and `structure.md`.
**Brownfield**: Populate all files with detected stack, structure, and conventions.
**If steering files already exist**: Read them fully. Do NOT overwrite or discard existing content:
  - **Preserve** settled decisions, detected stack, conventions, content from other phases.
  - **Update** feature-specific section (Summary, current feature description).
  - **Append** new information alongside existing content.
  - **`aidlc-workflow.md`** — always overwrite (session-specific).
  - **`resources.md`** — merge: keep existing, add new.

## Step 7: Create Manifest

Create `{WORKFLOW_DIR}/{feature}/aidlc-manifest.yaml`:

```yaml
version: "2.2"
feature: "{feature}"
language: "{language}"
platform: "{platform}"
created: "{ISO timestamp}"
updated: "{ISO timestamp}"
state:
  status: "active"
  sharedPhases: []
  mode: null
  foundationSkipped: false
  implementationMode: null
  quickPath: false
artifacts:
  context:
    status: "draft"
    timestamp: "{ISO timestamp}"
    files: [context.md]
implementation:
  totalTasks: 0
  completedTasks: 0
  currentTask: null
  currentWave: null
context-summary:
  type: "{Greenfield/Brownfield}"
  stack: "{Primary language + framework}"
  architecture: "{Pattern}"
  feature: "{1-sentence description}"
  impact: "{New standalone / Extends existing / Cross-cutting}"
  complexity: "{Low/Medium/High}"
  teamSize: null
  recommendations: { personas: false, units: false, nfr: false }
decisions: {}
steering:
  updatedBy:
    product: [context]
    tech: [context]
    structure: [context]
units: []
```

## Step 8: Create Audit Trail

Create `{WORKFLOW_DIR}/{feature}/audit.md` with header: `# Audit Trail — {feature}`

## Step 9: Validate

- ✅ Project type identified (greenfield/brownfield)
- ✅ Technology stack documented (if brownfield)
- ✅ Architecture pattern identified (if brownfield)
- ✅ Feature impact assessment complete
- ✅ Recommendations provided (Personas, Units, NFR)
- ✅ All steering files generated
- ✅ Manifest created

## Step 10: Present Results

```
📍 Context Assessment

[Summary of findings]

- **Project Type**: [Greenfield/Brownfield]
- **Stack**: [Detected or N/A]
- **Architecture**: [Detected or N/A]
- **Impact**: [New standalone / Extends existing / Cross-cutting]
- **Recommendations**: Personas [Yes/No], Units [Yes/No], NFR [Yes/No]

## Recommended Workflow

[ASCII workflow diagram — tailored to project complexity]

Artifact at `{SPECS_DIR}/{feature}/context.md`.

---
🔲 **Your turn**:
- ✅ "proceed" — move to requirements
- ✏️ "change [what]" — request edits
```

**Generate workflow diagram** based on recommendations. Use top-down ASCII art. Show ONLY the recommended path for this project.

Diagram templates:
- **Simple** (Units=No): Context → Requirements → Design → Tasks → Implement → Code Review
- **Complex greenfield** (Units=Yes): Context → Requirements → Decomposition → Foundation → [Unit cycles] → Solutions Review → Code Review
- **Complex brownfield** (Units=Yes): Context → Requirements → Decomposition → [Unit cycles] → Solutions Review → Code Review (skip Foundation)
- **With prototype**: Context → Requirements ↔ Prototype → then continue normal path

**STOP and wait for user approval.**

On approval: update manifest (`artifacts.context.status` → `"approved"`, add `"context"` to `state.sharedPhases`). Append audit entry. Then auto-continue to requirements.
