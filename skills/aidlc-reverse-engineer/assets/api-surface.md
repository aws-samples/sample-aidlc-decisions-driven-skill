# API Surface — Output Template

**Path**: `{OUTPUT_DIR}/api-surface.md`

~~~markdown
<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->
# API Surface

## Summary

[detected] endpoints across [count] route groups. [Brief characterization of API style, versioning, auth coverage.]

## Endpoints

| Method | Path | Handler | Auth | Description |
|---|---|---|---|---|
| [GET/POST/...] | [/api/...] | [file:function] | [yes/no/optional] | [description] |

## Endpoint Details

### [Route Group — e.g., /api/users]

#### [METHOD /path]

- **Handler**: `[file:function]`
- **Middleware**: [list]
- **Request**: `[shape or schema reference]`
- **Response**: `[shape or schema reference]`
- **Errors**: [status codes and conditions]

## Auth Patterns

| Pattern | Type | Applied To | Implementation |
|---|---|---|---|
| [name] | [JWT/session/API-key/OAuth] | [routes or groups] | [file:function] |
~~~
