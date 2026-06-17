# API Design Guide

Reference guide for API design patterns and best practices.

## REST API Conventions

### HTTP Methods
- **GET**: Retrieve resources (idempotent, safe)
- **POST**: Create resources (not idempotent)
- **PUT**: Update/replace resources (idempotent)
- **PATCH**: Partial update (not idempotent)
- **DELETE**: Remove resources (idempotent)

### URL Structure
```
/api/v1/resources
/api/v1/resources/{id}
/api/v1/resources/{id}/sub-resources
```

### Status Codes
- **200 OK**: Successful GET, PUT, PATCH
- **201 Created**: Successful POST
- **204 No Content**: Successful DELETE
- **400 Bad Request**: Invalid input
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource doesn't exist
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error

## Pagination

### Offset-Based
```
GET /api/v1/resources?page=2&limit=20
```

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

### Cursor-Based
```
GET /api/v1/resources?cursor=abc123&limit=20
```

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "def456",
    "hasMore": true
  }
}
```

## Error Response Format

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  }
}
```

## Rate Limiting

**Headers**:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1234567890
```

## Versioning

### URL-Based (Recommended)
```
/api/v1/resources
/api/v2/resources
```

### Header-Based
```
Accept: application/vnd.api+json; version=1
```

## Authentication

### JWT Bearer Token
```
Authorization: Bearer <token>
```

### API Key
```
X-API-Key: <key>
```

## Best Practices

1. Use nouns for resources, not verbs
2. Use plural names for collections
3. Use HTTP methods correctly
4. Return appropriate status codes
5. Include request IDs for tracing
6. Implement rate limiting
7. Version your API
8. Document with OpenAPI/Swagger
