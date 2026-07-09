# Steering: Resources — Output Template

Generate `{BLUEPRINTS_DIR}/resources.md` with this structure (canonical, platform-agnostic — no front-matter; the platform shim references it).

User fills in available resources. Phases 2, 4, and 6 check this file to enrich artifacts.
**If file already exists**: Read fully. Preserve all existing resource entries. Add newly discovered resources alongside existing ones.

```markdown
# External Resources

## Design Resources
- **Design tool**: [URL or "none" — e.g., Figma, Sketch, Adobe XD]
- **Design system docs**: [URL, path, or "none"]
- **Wireframes/mockups**: [path or "none"]

## API Resources
- **OpenAPI/Swagger spec**: [path, URL, or "none"]
- **GraphQL schema**: [path or "none"]
- **Existing API docs**: [URL or "none"]

## Knowledge Resources
- **Documentation**: [URLs or "none"]
- **Internal wiki**: [URL or "none"]
- **Reference implementations**: [repo URL or path or "none"]

## Available Tools
- [ ] Design tool MCP server (Figma, Sketch, etc.)
- [ ] Web search
- [ ] Other MCP servers: ___

## Notes
[Additional context about accessing these resources]
```
