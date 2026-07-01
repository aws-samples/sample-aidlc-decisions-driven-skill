# GitHub Actions — Production Templates

<!-- last_verified: 2026-06-30 -->

> **Usage**: Load when D5 CI platform = GitHub Actions. Read ONLY the stack section matching the project + the deploy target section matching D5.
>
> **Version resolution**: Templates use placeholder versions (e.g., `actions/checkout@v4`). At generation time, use web search to verify current major versions of referenced GHA actions. If verification unavailable, use versions shown here as defaults.

---

## Pipeline Structure (All Stacks)

Standard job flow:
```
build-and-test → security → deploy-dev → deploy-production
```

### Common Configuration

```yaml
name: CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions:
  contents: read
  packages: write
  id-token: write  # For OIDC auth (AWS/GCP)
```

---

## Stack: Node.js / TypeScript

```yaml
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:{DB_VERSION}
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '{NODE_VERSION}'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - run: npm run lint
      - run: npx tsc --noEmit
      - run: npm test
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/test_db
          NODE_ENV: test
      - uses: actions/upload-artifact@v4
        if: github.ref == 'refs/heads/main'
        with:
          name: build-output
          path: dist/
          retention-days: 3

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript-typescript
      - uses: github/codeql-action/analyze@v3
```

## Stack: Python / FastAPI

```yaml
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:{DB_VERSION}
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '{PYTHON_VERSION}'
          cache: 'pip'
      - run: pip install -r requirements.txt -r requirements-dev.txt
      - run: ruff check .
      - run: mypy src/
      - run: pytest --cov=src --cov-report=xml -v
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/test_db
      - uses: actions/upload-artifact@v4
        if: github.ref == 'refs/heads/main'
        with:
          name: app-source
          path: |
            src/
            requirements.txt
            alembic/
          retention-days: 3

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '{PYTHON_VERSION}'
      - run: pip install safety && safety check -r requirements.txt
```

## Stack: Java / Spring Boot

```yaml
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:{DB_VERSION}
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '{JAVA_VERSION}'
          cache: 'gradle'
      - run: ./gradlew build
        env:
          SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5432/test_db
          SPRING_DATASOURCE_USERNAME: postgres
          SPRING_DATASOURCE_PASSWORD: test
      - uses: actions/upload-artifact@v4
        if: github.ref == 'refs/heads/main'
        with:
          name: app-jar
          path: build/libs/*.jar
          retention-days: 3

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '{JAVA_VERSION}'
          cache: 'gradle'
      - run: ./gradlew dependencyCheckAnalyze
```

## Stack: Go

```yaml
jobs:
  build-and-test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:{DB_VERSION}
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test_db
        ports: ['5432:5432']
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '{GO_VERSION}'
      - run: go build ./...
      - run: golangci-lint run
      - run: go test -race -coverprofile=coverage.out ./...
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/test_db
      - uses: actions/upload-artifact@v4
        if: github.ref == 'refs/heads/main'
        with:
          name: binary
          path: bin/
          retention-days: 3

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: go install golang.org/x/vuln/cmd/govulncheck@latest && govulncheck ./...
```

---

## Deploy Target: Docker → Cloud Run (GCP)

```yaml
  deploy-dev:
    needs: [build-and-test, security]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: development
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - uses: actions/checkout@v4
      - id: auth
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.GCP_WIF_PROVIDER }}
          service_account: ${{ secrets.GCP_SA_EMAIL }}
      - uses: google-github-actions/setup-gcloud@v2
      - name: Build and push
        run: |
          gcloud auth configure-docker {REGION}-docker.pkg.dev --quiet
          docker build -t {REGION}-docker.pkg.dev/${{ secrets.GCP_PROJECT }}/{REPO}/{SERVICE}:${{ github.sha }} .
          docker push {REGION}-docker.pkg.dev/${{ secrets.GCP_PROJECT }}/{REPO}/{SERVICE}:${{ github.sha }}
      - name: Deploy
        id: deploy
        run: |
          gcloud run deploy {SERVICE} \
            --image {REGION}-docker.pkg.dev/${{ secrets.GCP_PROJECT }}/{REPO}/{SERVICE}:${{ github.sha }} \
            --region {REGION} \
            --platform managed \
            --set-env-vars "NODE_ENV=development,LOG_LEVEL=debug" \
            --set-secrets "DATABASE_URL={SECRET_NAME}:latest" \
            --min-instances 0 --max-instances 5 \
            --memory 512Mi --cpu 1 --timeout 60s \
            --port {PORT}
          echo "url=$(gcloud run services describe {SERVICE} --region {REGION} --format 'value(status.url)')" >> "$GITHUB_OUTPUT"
      - name: Smoke test
        run: |
          sleep 5
          curl -sf "${{ steps.deploy.outputs.url }}/health" | grep -q '"status"'

  deploy-production:
    needs: [deploy-dev]
    runs-on: ubuntu-latest
    environment:
      name: production
      url: ${{ steps.deploy.outputs.url }}
    steps:
      # Same as dev with production secrets and settings
      # --min-instances 1 --max-instances 20 --set-env-vars "NODE_ENV=production,LOG_LEVEL=info"
```

## Deploy Target: Docker → ECS Fargate (AWS)

```yaml
  deploy-dev:
    needs: [build-and-test, security]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: {AWS_REGION}
      - uses: aws-actions/amazon-ecr-login@v2
        id: ecr
      - name: Build and push
        env:
          REGISTRY: ${{ steps.ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $REGISTRY/{SERVICE}:$IMAGE_TAG .
          docker push $REGISTRY/{SERVICE}:$IMAGE_TAG
      - name: Deploy to ECS
        run: |
          # Update task definition with new image
          TASK_DEF=$(aws ecs describe-task-definition --task-definition {SERVICE}-dev --query taskDefinition)
          NEW_TASK_DEF=$(echo $TASK_DEF | jq --arg IMAGE "$REGISTRY/{SERVICE}:${{ github.sha }}" \
            '.containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn,.revision,.status,.registeredAt,.registeredBy,.requiresAttributes,.compatibilities)')
          NEW_ARN=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK_DEF" --query 'taskDefinition.taskDefinitionArn' --output text)
          aws ecs update-service --cluster {CLUSTER} --service {SERVICE}-dev --task-definition $NEW_ARN
          aws ecs wait services-stable --cluster {CLUSTER} --services {SERVICE}-dev
      - name: Smoke test
        run: |
          URL=$(aws elbv2 describe-target-groups --names {SERVICE}-dev --query 'TargetGroups[0].LoadBalancerArns[0]' --output text)
          # Resolve ALB DNS and health check
```

## Deploy Target: Docker → Kubernetes

```yaml
  deploy-dev:
    needs: [build-and-test, security]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v4
      - uses: azure/setup-kubectl@v4
      - uses: azure/k8s-set-context@v4
        with:
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
      - name: Build and push
        run: |
          docker build -t {REGISTRY}/{SERVICE}:${{ github.sha }} .
          docker push {REGISTRY}/{SERVICE}:${{ github.sha }}
      - name: Deploy
        run: |
          kubectl set image deployment/{SERVICE} {SERVICE}={REGISTRY}/{SERVICE}:${{ github.sha }} -n {NAMESPACE}
          kubectl rollout status deployment/{SERVICE} -n {NAMESPACE} --timeout=300s
      - name: Verify
        run: |
          kubectl get pods -l app={SERVICE} -n {NAMESPACE} -o wide
          # Port-forward and health check, or use ingress URL
```

## Deploy Target: Serverless (AWS Lambda)

```yaml
  deploy-dev:
    needs: [build-and-test, security]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    runs-on: ubuntu-latest
    environment: development
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: {AWS_REGION}
      - uses: actions/setup-node@v4
        with:
          node-version: '{NODE_VERSION}'
          cache: 'npm'
      - run: npm ci
      - name: Deploy with SAM
        run: |
          sam build
          sam deploy --stack-name {SERVICE}-dev --no-confirm-changeset --no-fail-on-empty-changeset \
            --parameter-overrides Environment=dev
```

---

## Dockerfile Template

```dockerfile
# Multi-stage build — {STACK}
FROM node:{NODE_VERSION}-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
COPY . .
RUN npm run build

FROM node:{NODE_VERSION}-slim AS production
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /app
COPY --from=builder --chown=app:app /app/dist ./dist
COPY --from=builder --chown=app:app /app/node_modules ./node_modules
COPY --from=builder --chown=app:app /app/package.json ./
USER app
EXPOSE {PORT}
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://localhost:{PORT}/health').then(r=>{if(!r.ok)throw r})" || exit 1
STOPSIGNAL SIGTERM
CMD ["node", "dist/app.js"]
```

---

## Secrets Configuration

| Secret | Where to Set | Used By |
|---|---|---|
| `GCP_WIF_PROVIDER` | GitHub → Settings → Secrets | GCP auth (OIDC) |
| `GCP_SA_EMAIL` | GitHub → Settings → Secrets | GCP service account |
| `GCP_PROJECT` | GitHub → Settings → Secrets | Registry/deploy target |
| `AWS_ROLE_ARN` | GitHub → Settings → Secrets | AWS auth (OIDC) |
| `DATABASE_URL` | Platform secret manager | App runtime |
| `SENTRY_DSN` | GitHub → Settings → Secrets | Error tracking (if applicable) |

**Prefer OIDC over long-lived keys** — both GCP Workload Identity Federation and AWS OIDC are supported natively by GitHub Actions.

---

## Rollback Patterns

### Cloud Run
```bash
# Rollback to previous revision
gcloud run services update-traffic {SERVICE} --region {REGION} --to-revisions LATEST=0,{PREV_REVISION}=100
```

### ECS
```bash
# Rollback to previous task definition
aws ecs update-service --cluster {CLUSTER} --service {SERVICE} --task-definition {PREV_TASK_DEF}
```

### Kubernetes
```bash
kubectl rollout undo deployment/{SERVICE} -n {NAMESPACE}
```
