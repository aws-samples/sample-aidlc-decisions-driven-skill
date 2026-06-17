# Technology Catalog — Non-Functional Requirements

> Load ONLY if NFR questions are relevant (production deployment, performance targets, compliance).

### Performance
- **Performance Targets**: response time, throughput, concurrent users
- **Performance Optimization**: caching, CDN, database indexing, code splitting
- **Load Testing Requirements**: expected load, peak load, testing approach

### Scalability
- **Scalability Approach**: horizontal auto-scaling, vertical scaling, fixed capacity
- **Database Scaling**: read replicas, sharding, connection pooling
- **Rate Limiting**: per-user, per-IP, per-endpoint, none

### Security
- **Security Level**: basic, standard, enterprise, compliance-driven
- **Data Encryption**: at rest, in transit, both, none
- **Input Validation**: strict, standard, basic
- **Dependency Scanning**: automated, manual, none

### Availability & Reliability
- **Availability Target**: 99.9%, 99.5%, best effort
- **Disaster Recovery**: backup strategy, RTO/RPO targets
- **Health Checks**: endpoint-based, process-based, none
- **Circuit Breaker**: enabled, disabled, specific services only

### Monitoring & Alerting
- **Monitoring Depth**: basic logging, logs + metrics, full observability
- **Alert Channels**: email, Slack, PagerDuty, SMS
- **Alert Conditions**: error rate, response time, resource utilization
