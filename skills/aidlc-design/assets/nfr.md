# Non-Functional Requirements Template

**Path**: `{SPECS_DIR}/{feature}/design/nfr.md`

Generated only if NFR questions answered in D3.

```markdown
# Non-Functional Requirements & Infrastructure

---

## Performance

- **Response Time**: [Target — e.g., "< 200ms p95"]
- **Throughput**: [Expected X req/sec, Peak Y req/sec]
- **Concurrent Users**: [Normal X, Peak Y]

---

## Scalability

- **Horizontal Scaling**: Min [X] → Max [Y] instances, trigger: [condition]
- **Data Growth**: [Current size, growth rate]

---

## Security

- **Authentication**: [Method]
- **Authorization**: [Model — RBAC/ABAC]
- **Encryption**: At rest [method], In transit [TLS version]
- **Compliance**: [Standards — GDPR/HIPAA/SOC 2]
- **Secret Management**: [AWS Secrets Manager/Vault]

**Roles & Permissions**:
| Role | Permissions |
|------|-------------|
| Admin | [List] |
| User | [List] |

---

## Availability & Reliability

- **Uptime SLA**: [99.9%/99.95%/99.99%]
- **RPO**: [Max data loss]
- **RTO**: [Max downtime]
- **Backup**: [Frequency and retention]
- **Health Check**: [Endpoint and frequency]

---

## Infrastructure

### Compute
| Component | Service | Configuration |
|-----------|---------|---------------|
| [Component] | [Lambda/ECS/EC2] | [Config] |

### Storage
| Data Type | Service | Configuration |
|-----------|---------|---------------|
| [Type] | [RDS/DynamoDB/S3] | [Config] |

### Networking
| Component | Service | Configuration |
|-----------|---------|---------------|
| [Component] | [ALB/CDN] | [Config] |

---

## Caching

| Data | Technology | TTL | Invalidation |
|------|-----------|-----|--------------|
| [Data type] | [Redis/Memcached] | [Duration] | [Strategy] |

---

## Data Management

- **Migration Tool**: [Prisma Migrate/Flyway]
- **Retention**: [Entity]: [Duration]
- **Archival**: [Strategy]
- **Deletion**: [Soft/Hard delete]

---

## Observability

| Concern | Tool | Configuration |
|---------|------|---------------|
| Logging | [CloudWatch/ELK] | [Retention] |
| Metrics | [CloudWatch/Prometheus] | [Key metrics] |
| Tracing | [X-Ray/Jaeger] | [Sampling rate] |
| Alerting | [CloudWatch/PagerDuty] | [Thresholds] |

---

## CI/CD & Deployment

Deployment strategy and environment configuration:
- **Deploy Strategy**: [Blue-Green/Canary/Rolling]
- **Rollback**: [Approach and estimated time]

| Environment | Trigger | URL |
|-------------|---------|-----|
| Development | Push to develop | [URL] |
| Staging | Push to main | [URL] |
| Production | Manual approval | [URL] |
```
