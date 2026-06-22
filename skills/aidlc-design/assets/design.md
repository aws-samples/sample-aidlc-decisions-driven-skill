# Design Template (Main Entry Point)

**Path**: `{SPECS_DIR}/{feature}/design.md`
**Use when**: Complex projects (11+ stories or multiple domains) — generates modular design.md + design/ folder
**For simple projects**: Use `design-compact.md` instead (single file)

```markdown
# Design Document: [Feature Name]

## Summary
<!-- 10-line max digest for downstream phases. Later phases can read ONLY this section. -->
- **Architecture**: [Style] — [1-sentence rationale]
- **Stack**: [Frontend] / [Backend] / [Database] / [Infra]
- **Components**: [X] — [list names]
- **Entities**: [Y] — [list names]
- **Endpoints**: [Z] — [list key ones]
- **Integrations**: [list external services]
- **Testing**: [PBT Yes/No] — [NFR Yes/No]
- **Key Decisions**: [top 3 from D3]

## Architecture

### System Context Diagram
```
[ASCII diagram showing system boundaries, components, and external dependencies]
```

### Technology Stack
- **Frontend**: [Framework/library] (if applicable)
- **Backend**: [Framework/runtime]
- **Database**: [Database technology]
- **Infrastructure**: [Cloud provider/platform]
- **Key Libraries**: [Major dependencies]

### Key Design Decisions
1. **[Decision 1]**: [Brief rationale]
2. **[Decision 2]**: [Brief rationale]
3. **[Decision 3]**: [Brief rationale]

## Traceability

<!-- COVERAGE RULE: Every US-* from requirements.md MUST appear in this table.
     If a requirement has no corresponding design element, mark Status as "⚠️ Gap"
     and add a note explaining why (deferred, out of scope, covered by another US). -->

| Requirement | Component(s) | API Endpoint(s) | Data Entity | Design File | Status |
|---|---|---|---|---|---|
| [US-X] | [Component] | [METHOD /path] | [Entity] | [design/file.md] | ✅ Covered |

### Coverage Summary
- **Requirements covered**: [X] / [Total] from requirements.md
- **Gaps**: [list any US-* not addressed, with reason]
- **Components without requirement**: [list any component not traced to a US-*, with justification]

## Open Questions & Risks

| # | Question/Risk | Impact | Status |
|---|--------------|--------|--------|
| 1 | [Item] | [High/Medium/Low] | [Open/Mitigated] |

## Detailed Specifications

- [Components](design/components.md) — component breakdown and interfaces
- [Data Model](design/data-model.md) — entities, relationships, schemas
- [API Specification](design/api-spec.md) — endpoints and contracts
- [Integration](design/integration.md) — external services and inter-unit communication
- [Implementation](design/implementation.md) — directory structure, setup, conventions
- [Non-Functional Requirements](design/nfr.md) — performance, security, infrastructure *(if applicable)*
- [Correctness Properties](design/correctness.md) — PBT specifications *(if applicable)*

## External References
[If external resources were used — otherwise omit this section]

| Source | Type | Used in |
|--------|------|---------|
| [URL or doc path] | [Design system / API spec / Documentation] | [Which design file — e.g., "components.md", "api-spec.md"] |
```
