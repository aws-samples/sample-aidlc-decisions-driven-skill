# Action: design-edit

Follow the **Edit Action Pattern** from `aidlc/shared/base.md`. Phase-specific details:

- **Validation**: Cross-references between design files correct, all D3 choices still reflected, no orphaned components or endpoints, no assumptions beyond D3, testing-strategy.md consistent with implementation.md directory structure
- **Cascade rule**: Renaming an entity → update data-model, api-spec, and components. Changing an endpoint → update api-spec and integration. Changing a component → update testing-strategy.md coverage mapping. Changing testing frameworks → update testing-strategy.md and implementation.md.
- **No-Assumptions Rule**: Do not introduce choices not in D3
- **Downstream to mark outdated**: `tasks` (if exists)
