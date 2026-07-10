# Blueprint: Structure — Output Template

Generate `{BLUEPRINTS_DIR}/structure.md` (canonical, platform-agnostic — no front-matter; the platform shim references it).

**Progressive enrichment**: Phase 1 creates (detected or placeholders), Phase 4 updates with design structure.
**If file already exists**: Preserve all existing content. Only update placeholders or add newly detected entries. Never remove previously documented structure.

## Structure

```yaml
sections:
  summary: # 3-line max
    - repo type, key source directories, main entry points
  repository:
    - type: Monorepo/Multi-repo/Single/"Pending D3"
    - root: brief description
  key_directories: table (directory, purpose, key contents)
    # Brownfield: detect from codebase. Greenfield: "will be defined during design phase"
  key_files: table (file, purpose, notes)
    # Brownfield: detect configs. Greenfield: placeholder
  entry_points: table (entry, type, description)
    # Brownfield: detect. Greenfield: placeholder
  module_dependencies: # Brownfield only
    - ascii_import_graph: showing dependency flow
    - dependency_rules: detected from patterns
  data_flow: # Brownfield only
    - ascii_request_lifecycle: middleware → handler → service → repo → DB
  key_abstractions: # Brownfield only
    - table: abstraction, location, purpose, used_by
  test_organization: # Brownfield only
    - location, types present, utilities, coverage, run command
  build_deploy: # Brownfield only
    - build output, container, deploy target
```

## Rules
- Brownfield: detect from actual files — directory tree, imports, configs
- Greenfield: use placeholders for Phase 4 to fill
- Never remove previously documented entries when updating
