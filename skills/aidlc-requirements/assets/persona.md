# Persona — Output Template

Generate `{SPECS_DIR}/{feature}/personas.md` with this structure.
Only generate if D1 indicated "Yes" for personas or multiple user types.

```markdown
# Personas

## Summary
<!-- Compact digest for downstream phases. -->
- **User Types**: [X] personas
- **Key Roles**: [list names]
- **Design Implications**: [RBAC needed / Mobile-first / etc.]

## Overview
This feature serves [X] distinct user types.

---

## [Persona Name]

**Role**: [Job title or user type]

**Goals**:
- [Primary goal]
- [Secondary goal]

**Pain Points**:
- [Current frustration #1]
- [Current frustration #2]

**User Journey**: [Entry] → [Action] → [Outcome]

**Implications**: [How this persona affects requirements — e.g., "Needs simplified UI", "Mobile-first"]

---

## [Persona 2 Name]

[Same structure]

---

## Design Implications

- **Architecture**: [How personas affect design — e.g., "Need RBAC"]
- **UI/UX**: [Interface needs]
- **Data & Privacy**: [Data access patterns, privacy considerations]
```
