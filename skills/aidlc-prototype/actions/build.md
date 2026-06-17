# Action: build-prototype

## Step 1: Gather Design Context

Check for available design resources:

1. Read `{STEERING_DIR}/resources.md` if it exists — check Design Resources section
2. For each available source, extract visual direction:
   - **Design tool** (Figma, etc.): If design tool MCP is available, read screens, component inventory, design tokens (colors, typography, spacing). Use these to style the prototype.
   - **Design system docs**: Read referenced docs → extract color palette, font stack, component naming, spacing scale. Apply to prototype UI.
   - **Wireframes/mockups**: Read referenced files → use as layout reference for prototype screens.
3. If no design resources exist → use a clean default (system fonts, neutral colors, simple layout). Note this in the prototype README.

The goal is not pixel-perfect fidelity — it's making the prototype feel like the real product so user feedback is about flows and features, not visual polish.

## Step 2: Scope the Prototype

Read requirements. Select the top 3-5 highest-priority stories that represent the core user experience. Skip:
- Infrastructure stories (auth, deployment, monitoring)
- Edge cases and error handling
- Low-priority nice-to-haves

Present the selected stories to the user:

```
📍 Prototype Scope

I'll prototype these stories:
1. [Story ID]: [title] (Priority: High)
2. [Story ID]: [title] (Priority: High)
3. [Story ID]: [title] (Priority: High)
...

Skipping: [brief list of what's excluded and why]

{If design resources found: "Design context: Using [design system name / Figma components / color palette from docs]"}
{If no design resources: "No design resources found — using clean defaults."}

---
🔲 **Your turn**:
- ✅ "go" — build the prototype
- ✏️ "add [story]" or "remove [story]" — adjust scope
```

**STOP and wait for confirmation.**

## Step 3: Build the Prototype

Implement the confirmed stories with these constraints:
- **No architecture**: Flat file structure, no layers, no patterns
- **No tests**: This code is throwaway
- **No real data layer**: In-memory arrays, JSON files, or hardcoded data
- **No auth**: Skip authentication/authorization entirely
- **No error handling**: Happy path only
- **Single entry point**: One file or minimal files to run
- **ALL code goes to `.aidlc/prototype/{feature}/`** — NEVER write to workspace root

**UI styling** (apply design context from Step 1):
- If design tokens available (from Figma/design system): Use the actual color palette, font stack, spacing scale, and border radius values. Import or inline them.
- If wireframes/mockups available: Follow the layout structure — header placement, navigation pattern, content areas, form layouts.
- If component library specified in design system: Use it directly (e.g., if design system says Material UI, install and use it).
- If no design resources: Use a lightweight CSS framework (e.g., Pico CSS, Simple.css) for clean defaults. Note "no design system specified" in README.

**Non-web prototypes** (adapt scaffolding based on project type from context.md):
- **CLI tool**: Use commander/yargs for commands + inquirer/prompts for interactive input. Single entry point file. Hardcoded responses.
- **API-only service**: Use Express/Fastify with a few routes. Add Swagger UI (`/docs`) for interactive testing. In-memory data store.
- **Mobile app**: Use Expo (React Native) for quick cross-platform scaffold. Single screen with navigation stub. Mock data.
- **Desktop app**: Use Electron with a minimal HTML UI, or a CLI prototype if UI isn't the focus.
- **Data pipeline**: Simple script that reads sample input, transforms, and writes output. Hardcoded sample data.

Include a `README.md` in the prototype directory with:
- How to run it (one command)
- What stories it demonstrates
- What's faked/hardcoded
- Design sources used (Figma URL, design system, or "none — using defaults")
- Known limitations

## Step 4: Report Findings

After building, reflect on what was learned. Present:

```
📍 Prototype Complete

Stories demonstrated: [list]
Run command: [command]
Code location: .aidlc/prototype/{feature}/

## Discoveries
- [Finding 1]: [what was learned]
- [Finding 2]: [what was harder than expected]
- [Finding 3]: [what was missing from requirements]

## Suggested Requirement Changes
- [suggestion 1]
- [suggestion 2]

---
🔲 **Your turn**:
- ✏️ "update requirements" — apply discoveries
- ✅ "proceed" — continue to design
- ✅ "discard" — delete prototype
```

**STOP and wait.**

## Step 5: Handle Response

- **"update requirements"**: Auto-apply the suggested changes to `{SPECS_DIR}/{feature}/requirements.md` as draft edits. Read the current file, apply changes (add/modify/remove stories based on discoveries), write the updated file. Then present the changes for user review:

```
📍 Requirements Updated (Draft)

Changes applied:
- [Added/Modified/Removed]: [story description]
- [Added/Modified/Removed]: [story description]

🔲 **Your turn**:
- ✅ "approve" — accept changes, continue to design
- ✏️ "change [what]" — adjust the edits
- ↩️ "revert" — undo changes, keep original requirements
```

  **STOP and wait.** On "approve": update manifest (`artifacts.requirements.timestamp`), mark downstream artifacts as `outdated` if they exist. Then auto-continue to the next phase. On "revert": restore the original requirements.md.

- **"proceed"**: The prototype stays for reference. Auto-continue: read the manifest to determine the routing recommendation (from the requirements phase), then read the appropriate next skill (`aidlc-decomposition` or `aidlc-design`) and follow its instructions.
- **"discard"**: Delete the `.aidlc/prototype/{feature}/` directory and all its contents. Confirm deletion. Then auto-continue same as "proceed".
