# CI/CD Platform Reference

## GitHub Actions

**Config path**: `.github/workflows/{name}.yml`
**Secrets**: `${{ secrets.NAME }}`
**Environment protection**: Settings → Environments → required reviewers
**Artifacts**: `actions/upload-artifact@v4`, `actions/download-artifact@v4`
**Caching**: `actions/cache@v4`
**Matrix builds**: `strategy.matrix`

Key patterns:
- Use `needs:` for job dependencies
- Use `environment:` for deployment protection rules
- Use `concurrency:` to prevent parallel deploys to same env
- Use reusable workflows for shared pipeline logic

## GitLab CI

**Config path**: `.gitlab-ci.yml`
**Secrets**: `$VARIABLE_NAME` (Settings → CI/CD → Variables)
**Environment protection**: Settings → CI/CD → Protected environments
**Artifacts**: `artifacts:` keyword in job
**Caching**: `cache:` keyword

Key patterns:
- Use `stages:` for pipeline order
- Use `needs:` for DAG-based execution
- Use `environment:` for deploy tracking
- Use `rules:` for conditional execution
- Use `include:` for shared templates

## AWS CodePipeline / CodeBuild

**Config paths**: `buildspec.yml` (CodeBuild), pipeline via CDK/CloudFormation/Console
**Secrets**: AWS Secrets Manager, Systems Manager Parameter Store
**Environment protection**: Manual approval actions in pipeline
**Artifacts**: S3 bucket (automatic between stages)

Key patterns:
- `buildspec.yml` phases: install, pre_build, build, post_build
- Use `parameter-store` or `secrets-manager` in env variables
- CodeDeploy for EC2/ECS deployments
- CloudFormation/CDK for infrastructure changes

## Azure DevOps

**Config path**: `azure-pipelines.yml`
**Secrets**: Pipeline variables (locked), Variable groups, Key Vault
**Environment protection**: Environments → Approvals and checks
**Artifacts**: Pipeline artifacts, Azure Artifacts feed

Key patterns:
- Use `stages:` → `jobs:` → `steps:` hierarchy
- Use `deployment` job type for environment tracking
- Use `strategy:` for deployment patterns (rolling, canary, blue-green)
- Use templates for reuse

## CircleCI

**Config path**: `.circleci/config.yml`
**Secrets**: Project Settings → Environment Variables, Contexts
**Environment protection**: Contexts with security groups
**Artifacts**: `store_artifacts`, `persist_to_workspace`

Key patterns:
- Use `workflows:` for pipeline orchestration
- Use `requires:` for job dependencies
- Use `approval` job type for manual gates
- Use orbs for reusable packages

## Jenkins

**Config path**: `Jenkinsfile`
**Secrets**: Credentials plugin, HashiCorp Vault
**Environment protection**: `input` step for manual approval
**Artifacts**: `archiveArtifacts`, `stash`/`unstash`

Key patterns:
- Declarative pipeline preferred over scripted
- Use `stages` → `stage` → `steps`
- Use `when` for conditional execution
- Use `parallel` for concurrent stages
