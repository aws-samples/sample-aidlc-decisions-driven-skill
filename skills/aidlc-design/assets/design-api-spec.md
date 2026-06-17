# API Specification — Output Template

**Path**: `{SPECS_DIR}/{feature}/design/api-spec.md`

Generate based on D3 api-style choice. Include ONLY the relevant section (REST, GraphQL, OR gRPC — not all).

## Structure

```yaml
sections:
  overview: api_style, base_url, auth_method (from D3)
  conventions: pagination, filtering, sorting, rate_limit, versioning
  error_format: JSON shape (code, message, details, requestId)
  # Include ONE matching API style:
  endpoints: # REST only — per resource group
    - method, path, description, auth, request_body, response, errors
  graphql_schema: # GraphQL only
    - type_definitions, queries, mutations, subscriptions, error_handling
  grpc_definitions: # gRPC only
    - proto_syntax, rpc_methods, message_definitions, error_handling
```

## Rules
- One endpoint per user story action (CRUD + custom operations)
- Include request/response JSON examples with realistic field values
- Error responses use format from foundation.md or D3 error handling choice
- Source traceability: link each endpoint to its requirement or decision
