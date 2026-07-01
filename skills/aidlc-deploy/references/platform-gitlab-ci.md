# GitLab CI — Production Templates

<!-- last_verified: 2026-06-30 -->

> **Usage**: Load when D5 CI platform = GitLab CI. Read ONLY the stack section matching the project + the deploy target section matching D5.
>
> **Version resolution**: Templates use placeholder image tags (e.g., `postgres:{DB_VERSION}`). At generation time, resolve current versions from manifest version map or web search.

---

## Pipeline Structure (All Stacks)

Standard stage flow:
```
build → test → security → deploy-dev → deploy-production
```

### Common Configuration

```yaml
stages:
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_TLS_CERTDIR: "/certs"

workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

default:
  interruptible: true
```

---

## Stack: Node.js / TypeScript

```yaml
variables:
  NODE_VERSION: "{NODE_VERSION}"

.node-setup:
  image: node:${NODE_VERSION}
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
    policy: pull

build:
  extends: .node-setup
  stage: build
  cache:
    policy: pull-push
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/
      - node_modules/
    expire_in: 1 hour

test:
  extends: .node-setup
  stage: test
  services:
    - name: postgres:{DB_VERSION}
      alias: postgres
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: test
    DATABASE_URL: postgresql://postgres:test@postgres:5432/test_db
  script:
    - npm run lint
    - npx tsc --noEmit
    - npm test -- --coverage
  coverage: '/All files[^|]*\|[^|]*\s+([\d\.]+)/'
  artifacts:
    reports:
      junit: junit.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

security:
  stage: security
  image: node:${NODE_VERSION}
  script:
    - npm audit --audit-level=high
  allow_failure: true
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Stack: Python / FastAPI

```yaml
variables:
  PYTHON_VERSION: "{PYTHON_VERSION}"

.python-setup:
  image: python:${PYTHON_VERSION}
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .venv/
    policy: pull
  before_script:
    - python -m venv .venv
    - source .venv/bin/activate
    - pip install -r requirements.txt -r requirements-dev.txt

build:
  extends: .python-setup
  stage: build
  cache:
    policy: pull-push
  script:
    - python -m compileall src/
  artifacts:
    paths:
      - src/
      - .venv/
    expire_in: 1 hour

test:
  extends: .python-setup
  stage: test
  services:
    - name: postgres:{DB_VERSION}
      alias: postgres
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: test
    DATABASE_URL: postgresql://postgres:test@postgres:5432/test_db
  script:
    - ruff check .
    - mypy src/
    - pytest --cov=src --cov-report=xml --junitxml=report.xml -v
  artifacts:
    reports:
      junit: report.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

security:
  stage: security
  image: python:${PYTHON_VERSION}
  script:
    - pip install safety
    - safety check -r requirements.txt
  allow_failure: true
```

## Stack: Java / Spring Boot

```yaml
variables:
  JAVA_VERSION: "{JAVA_VERSION}"

.java-setup:
  image: gradle:{JAVA_VERSION}-jdk
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - .gradle/caches/
      - .gradle/wrapper/
    policy: pull

build:
  extends: .java-setup
  stage: build
  cache:
    policy: pull-push
  script:
    - ./gradlew assemble
  artifacts:
    paths:
      - build/libs/*.jar
    expire_in: 1 hour

test:
  extends: .java-setup
  stage: test
  services:
    - name: postgres:{DB_VERSION}
      alias: postgres
  variables:
    SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/test_db
    SPRING_DATASOURCE_USERNAME: postgres
    SPRING_DATASOURCE_PASSWORD: test
  script:
    - ./gradlew check
  artifacts:
    reports:
      junit: build/test-results/test/*.xml

security:
  extends: .java-setup
  stage: security
  script:
    - ./gradlew dependencyCheckAnalyze
  allow_failure: true
```

## Stack: Go

```yaml
variables:
  GO_VERSION: "{GO_VERSION}"

.go-setup:
  image: golang:${GO_VERSION}
  cache:
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - /go/pkg/mod/
    policy: pull

build:
  extends: .go-setup
  stage: build
  cache:
    policy: pull-push
  script:
    - go build -o bin/app ./cmd/...
  artifacts:
    paths:
      - bin/
    expire_in: 1 hour

test:
  extends: .go-setup
  stage: test
  services:
    - name: postgres:{DB_VERSION}
      alias: postgres
  variables:
    DATABASE_URL: postgresql://postgres:test@postgres:5432/test_db
    POSTGRES_PASSWORD: test
    POSTGRES_DB: test_db
  script:
    - golangci-lint run
    - go test -race -coverprofile=coverage.out ./...
    - go tool cover -func=coverage.out
  coverage: '/total:\s+\(statements\)\s+(\d+\.\d+)%/'

security:
  extends: .go-setup
  stage: security
  script:
    - go install golang.org/x/vuln/cmd/govulncheck@latest
    - govulncheck ./...
  allow_failure: true
```

---

## Deploy Target: Docker → Cloud Run (GCP)

```yaml
.deploy-cloudrun:
  stage: deploy
  image: google/cloud-sdk:slim
  before_script:
    - echo "$GCP_SA_KEY" | gcloud auth activate-service-account --key-file=-
    - gcloud config set project $GCP_PROJECT

deploy-dev:
  extends: .deploy-cloudrun
  environment:
    name: development
    url: $DEV_URL
  variables:
    ENV: dev
  script:
    - gcloud auth configure-docker {REGION}-docker.pkg.dev --quiet
    - docker build -t {REGION}-docker.pkg.dev/$GCP_PROJECT/{REPO}/{SERVICE}:$CI_COMMIT_SHA .
    - docker push {REGION}-docker.pkg.dev/$GCP_PROJECT/{REPO}/{SERVICE}:$CI_COMMIT_SHA
    - |
      gcloud run deploy {SERVICE} \
        --image {REGION}-docker.pkg.dev/$GCP_PROJECT/{REPO}/{SERVICE}:$CI_COMMIT_SHA \
        --region {REGION} --platform managed \
        --set-env-vars "APP_ENV=development,LOG_LEVEL=debug" \
        --set-secrets "DATABASE_URL={SECRET}:latest" \
        --min-instances 0 --max-instances 5 \
        --memory 512Mi --timeout 60s
    - "URL=$(gcloud run services describe {SERVICE} --region {REGION} --format 'value(status.url)')"
    - 'curl -sf "$URL/health" | grep status'
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-production:
  extends: .deploy-cloudrun
  environment:
    name: production
    url: $PROD_URL
  script:
    # Same as dev with production config
    # --min-instances 1 --max-instances 20 --set-env-vars "APP_ENV=production,LOG_LEVEL=info"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

## Deploy Target: Docker → ECS Fargate (AWS)

```yaml
.deploy-ecs:
  stage: deploy
  image:
    name: amazon/aws-cli:latest
    entrypoint: [""]
  before_script:
    - aws configure set region $AWS_REGION

deploy-dev:
  extends: .deploy-ecs
  environment:
    name: development
  variables:
    CLUSTER: "{CLUSTER}-dev"
    SERVICE: "{SERVICE}-dev"
  script:
    - aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
    - docker build -t $ECR_REGISTRY/{SERVICE}:$CI_COMMIT_SHA .
    - docker push $ECR_REGISTRY/{SERVICE}:$CI_COMMIT_SHA
    - |
      TASK_DEF=$(aws ecs describe-task-definition --task-definition $SERVICE --query taskDefinition)
      NEW_TASK=$(echo $TASK_DEF | jq --arg IMG "$ECR_REGISTRY/{SERVICE}:$CI_COMMIT_SHA" \
        '.containerDefinitions[0].image = $IMG | del(.taskDefinitionArn,.revision,.status,.registeredAt,.registeredBy,.requiresAttributes,.compatibilities)')
      NEW_ARN=$(aws ecs register-task-definition --cli-input-json "$NEW_TASK" --query 'taskDefinition.taskDefinitionArn' --output text)
      aws ecs update-service --cluster $CLUSTER --service $SERVICE --task-definition $NEW_ARN
      aws ecs wait services-stable --cluster $CLUSTER --services $SERVICE
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-production:
  extends: .deploy-ecs
  environment:
    name: production
  variables:
    CLUSTER: "{CLUSTER}-prod"
    SERVICE: "{SERVICE}-prod"
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

## Deploy Target: Docker → Kubernetes

```yaml
.deploy-k8s:
  stage: deploy
  image:
    name: bitnami/kubectl:latest
    entrypoint: [""]
  before_script:
    - kubectl config use-context $KUBE_CONTEXT

deploy-dev:
  extends: .deploy-k8s
  environment:
    name: development
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl set image deployment/{SERVICE} {SERVICE}=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n {NAMESPACE}-dev
    - kubectl rollout status deployment/{SERVICE} -n {NAMESPACE}-dev --timeout=300s
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy-production:
  extends: .deploy-k8s
  environment:
    name: production
  script:
    - kubectl set image deployment/{SERVICE} {SERVICE}=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -n {NAMESPACE}-prod
    - kubectl rollout status deployment/{SERVICE} -n {NAMESPACE}-prod --timeout=300s
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      when: manual
```

---

## Secrets Configuration

| Variable | Where to Set | Masked | Protected |
|---|---|---|---|
| `GCP_SA_KEY` | Settings → CI/CD → Variables | Yes | Yes |
| `GCP_PROJECT` | Settings → CI/CD → Variables | No | Yes |
| `AWS_ACCESS_KEY_ID` | Settings → CI/CD → Variables | Yes | Yes |
| `AWS_SECRET_ACCESS_KEY` | Settings → CI/CD → Variables | Yes | Yes |
| `AWS_REGION` | Settings → CI/CD → Variables | No | No |
| `ECR_REGISTRY` | Settings → CI/CD → Variables | No | Yes |
| `KUBE_CONFIG` | Settings → CI/CD → Variables (File type) | Yes | Yes |

**Protected variables** only available on protected branches/tags — use for production secrets.

---

## Rollback Patterns

### Cloud Run
```bash
gcloud run services update-traffic {SERVICE} --region {REGION} --to-revisions {PREV}=100
```

### ECS
```bash
aws ecs update-service --cluster {CLUSTER} --service {SERVICE} --task-definition {PREV_TASK_DEF}
```

### Kubernetes
```bash
kubectl rollout undo deployment/{SERVICE} -n {NAMESPACE}
```
