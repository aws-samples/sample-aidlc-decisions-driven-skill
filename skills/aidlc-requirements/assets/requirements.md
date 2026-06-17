# Requirements — Output Template

**Path**: `{SPECS_DIR}/{feature}/requirements.md`

All acceptance criteria MUST use EARS notation (see `{SKILL_DIR}/references/ears-notation.md`).

## Structure

```yaml
sections:
  summary: # 10-line max, downstream reads ONLY this
    - total_stories, functional_areas, priority_distribution
    - user_types, key_entities, integrations
    - core_flows (1-line each, max 5)
  functional_areas: # grouped by domain
    per_story:
      - id (US-NNN), title, as_a, i_want, so_that
      - priority (High/Medium/Low)
      - acceptance_criteria: EARS notation (2+ per story)
      - dependencies, source (D1 / design screen / API spec)
  story_summary: table (ID, title, area, priority, dependencies)
  story_persona_matrix: # if personas — story × persona (Primary/Secondary/—)
  nonfunctional_notes: brief cross-cutting concerns
  external_references: # if used — source, stories_derived, what_was_used
```

## Rules
- Every feature area from D1 scope must have stories
- Every user type must appear in at least one story
- Every story must have 2+ EARS acceptance criteria
- Priority must be assigned (no "unassigned")
- Source traceability: link to decision or external resource that drove the story
