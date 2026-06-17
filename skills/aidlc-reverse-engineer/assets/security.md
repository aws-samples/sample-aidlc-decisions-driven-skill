# Security Assessment — Output Template

**Path**: `{OUTPUT_DIR}/security.md`
**Timestamp**: `<!-- Analyzed: {ISO timestamp} | Scope: {scope} -->`

## Structure

```yaml
sections:
  summary: auth coverage, input validation maturity, dependency health, secrets management, overall risk level
  auth_coverage:
    - table: area, protected (yes/partial/no), mechanism, gaps
    - authorization_model: pattern, roles, enforcement, gaps
  input_validation:
    - table: area (API/DB/user content/file uploads), validation present, library, gaps
  secrets_credentials:
    - findings: table (description, type, location file:line, risk)
    - management: approach, rotation, gitignore coverage
  dependency_vulnerabilities: table (package, version, issue, severity, CVE)
  security_headers: table (header/config, status, value, recommendation)
  data_exposure: table (risk, type, location, description)
  debt_summary: table (issue #, description, severity, category, location, remediation)
```

## Rules
- Every unprotected endpoint must be flagged
- Hardcoded secrets are always critical severity
- Cite file:line for every finding
