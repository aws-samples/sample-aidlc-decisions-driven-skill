# Action: Deployment Specification

## 1. Load context

Read from manifest and workflow artifacts:
- D5 decisions from `{WORKFLOW_DIR}/{feature}/decisions-deploy.md`
- `{WORKFLOW_DIR}/{feature}/build-report.md` for build context
- `{SPECS_DIR}/{feature}/design/implementation.md` for infrastructure requirements
- `{SPECS_DIR}/{feature}/design/operations.md` (if exists) for health probes, logging, metrics
- Existing CI/CD configs detected during decision gate
- Manifest `context-summary` for stack and feature info

## 2. Read template

Read the deployment template from `{SKILL_DIR}/assets/deployment.md`. Use its structure as the output format. Follow the template rules defined there.

**Do NOT generate from memory** — always read the template file first, even if you believe you've seen it earlier in this conversation.

## 3. Generate deployment specification

Write to `{SPECS_DIR}/{feature}/deployment.md`:

Follow the template structure. Fill all sections using D5 decisions and context gathered in Step 1.

### Content guidelines

- **Summary**: 10-line max digest — downstream steps (generate) can read ONLY this section + Files to Generate for quick reference
- **Pipeline architecture**: derive from D5-1 (platform), D5-4 (environments), D5-5 (promotion), D5-9 (migrations), D5-10 (verification)
- **Target infrastructure**: derive from D5-2 (target), design docs, operations.md
- **Security**: derive from D5-6 (secrets), design/implementation.md
- **Rollback**: derive from D5-8, target platform capabilities
- **Files to generate**: list every file that the generate step will produce, with paths and purpose — this is the contract between plan and generate
- **Risk assessment**: identify deployment-specific risks (not application risks)
- **Cost estimate**: provide rough ranges based on target platform pricing; mark as estimates

### Adaptation rules

- If D5-7 = "None" (no IaC): omit IaC files from "Files to Generate", simplify infrastructure section to describe manual setup steps
- If no database: omit "Database Migrations" section entirely
- If `design/operations.md` doesn't exist: use sensible defaults for health checks, note that operations design was not specified
- If simple project (solo dev, few services): keep sections brief, collapse low-value sections
- Never omit: Summary, Pipeline Architecture, Target Infrastructure, Files to Generate

## 4. Present deployment spec

```
📍 Deployment Specification — {feature}

**Target**: {D5-2 answer} via {D5-1 answer}
**Strategy**: {D5-3 answer}
**Environments**: {D5-4 answer}
**IaC**: {D5-7 answer}

Pipeline: {N} stages — {summary of flow}
Infrastructure: {brief topology summary}
Files to generate: {N} files

Full spec: `{SPECS_DIR}/{feature}/deployment.md`

---
🔲 **Your turn**:
- ✅ "approve" — proceed to generate deployment configs
- ✏️ "edit [section]" — modify a specific part of the spec
- 🔧 "change [decision]" — go back and revise a D5 answer
- ❓ "explain [section]" — get more detail on any part
```

**STOP — do NOT continue until user approves.**

On "edit [section]": update the spec, re-present summary.
On "change [decision]": note which D5 answer to revise, reload `{SKILL_DIR}/actions/decision-gate.md` for that question only.
On "approve": proceed to Step 5.

## 5. Store artifact reference

Update manifest:
```yaml
artifacts.deploy:
  status: "planned"
  timestamp: "{ISO timestamp}"
  files: [decisions-deploy.md, deployment.md]
```

## 6. Proceed

Load `{SKILL_DIR}/actions/generate.md`.

## 7. Audit entry

```
### [{ISO timestamp}] Deploy: Plan

**Phase**: deploy
**Action**: plan
**Artifacts**: deployment.md
**Outcome**: Deployment specification generated at {SPECS_DIR}/{feature}/deployment.md. Pipeline: {N} stages, Target: {target}, Environments: {env list}, Files planned: {N}. Awaiting generation.
```
