# CI/CD, Deployment & Operations Reference

## CI/CD Pipeline Stages
1. **Build**: Install dependencies, compile/transpile, run linters
2. **Test**: Unit tests, integration tests, coverage reports
3. **Security**: Dependency scan, static analysis, secret detection
4. **Deploy**: Build image, push to registry, deploy, smoke tests

## Deployment Strategies
- **Blue-Green**: Zero downtime, instant rollback, double resources
- **Canary**: Gradual rollout, real user feedback, complex routing
- **Rolling**: No extra resources, gradual, mixed versions
- **Recreate**: Simple, clean state, has downtime

## Rollback
- Blue-green/canary: instant (switch traffic back)
- Rolling/recreate: redeploy previous version
- Database: backward-compatible migrations, feature flags

## Operations
- **Monitoring**: Request rate, error rate, response time (p50/p95/p99), CPU, memory
- **Alerting**: Error rate >1% for 5min, p95 >target for 5min, CPU >80% for 10min
- **Incident Response**: Detection → Triage (P0-P4) → Response → Resolution → Post-Mortem
- **Maintenance**: Daily dashboards, weekly error logs, monthly dependency updates, quarterly DR tests
