# Steering: Product — Output Template

Generate `{STEERING_DIR}/product.md`.

**Kiro only**: Add `inclusion: always` YAML front-matter.
**Progressive enrichment**: Phase 1 creates, Phase 2 updates Target Users and Key Features.
**If file already exists**: Preserve all existing content. Update Summary for current feature. Append new users/features alongside existing — never remove previous entries.

## Structure

```yaml
sections:
  summary: # 3-line max
    - product (1-sentence), users (list), type + scope
  overview: one paragraph from user's request
  problem_statement: what problem, current pain point or gap
  target_users: # per user type
    - type: brief description and primary goal
  key_features: # per feature area
    - area: brief description
  domain_language: table (term, definition, example)
    # Brownfield: extract from class/module/table names. Greenfield: from user's request
  success_criteria: # how we know it's successful
    - metric: target
    # If unknown: "To be defined during requirements phase"
  constraints_assumptions:
    - constraints: timeline, budget, regulatory, technical
    - assumptions: things believed true but unverified
    # Brownfield: include "Must not break existing API contracts" etc.
  existing_user_journeys: # Brownfield only
    - current_flow, pain_points, workarounds
  project_type:
    - type: Greenfield/Brownfield
    - scope: New product/feature/enhancement/cross-cutting
```

## Rules
- Brownfield: populate from codebase analysis + user's request
- Greenfield: populate from user's request, mark unknowns
- Phase 2 (requirements) updates target_users and key_features — always append, never replace
