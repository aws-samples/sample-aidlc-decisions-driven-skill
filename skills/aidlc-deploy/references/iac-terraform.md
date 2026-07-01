# Terraform — Infrastructure Patterns

<!-- last_verified: 2026-06-30 -->

> **Usage**: Load when D5 IaC = Terraform. Read ONLY the sections matching the D5 deploy target + detected dependencies from design/operations.md.
>
> **Version resolution**: Provider versions shown as `~> 5.0` ranges. At generation time, use web search to verify current provider major versions from the Terraform Registry. Resource arguments may change between provider versions — verify against registry docs if unsure.

---

## Project Structure

```
infra/
├── main.tf              # Provider config, backend, module calls
├── variables.tf         # Input variables (all environments)
├── outputs.tf           # Output values (URLs, ARNs, connection strings)
├── versions.tf          # Required providers and versions
├── environments/
│   ├── dev.tfvars       # Dev-specific values
│   └── production.tfvars # Prod-specific values
└── modules/             # Optional — for reuse across environments
    ├── database/
    ├── container-service/
    └── networking/
```

### Backend and Provider

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    # OR
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }

  backend "s3" {
    bucket         = "{PROJECT}-terraform-state"
    key            = "{SERVICE}/{ENVIRONMENT}/terraform.tfstate"
    region         = "{REGION}"
    dynamodb_table = "{PROJECT}-terraform-locks"
    encrypt        = true
  }
  # OR for GCP:
  # backend "gcs" {
  #   bucket = "{PROJECT}-terraform-state"
  #   prefix = "{SERVICE}/{ENVIRONMENT}"
  # }
}

# main.tf
provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" { type = string }
variable "project" { type = string }
```

---

## Deploy Target: AWS ECS Fargate

### Networking (VPC)

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project}-${var.environment}"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
  enable_dns_hostnames = true
}
```

### Container Service

```hcl
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-${var.environment}"

  setting {
    name  = "containerInsights"
    value = var.environment == "production" ? "enabled" : "disabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.environment == "production" ? 512 : 256
  memory                   = var.environment == "production" ? 1024 : 512
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = var.project
    image = "${aws_ecr_repository.app.repository_url}:latest"
    portMappings = [{ containerPort = var.app_port, protocol = "tcp" }]

    environment = [
      { name = "NODE_ENV", value = var.environment },
      { name = "PORT", value = tostring(var.app_port) },
      { name = "LOG_LEVEL", value = var.environment == "production" ? "info" : "debug" }
    ]

    secrets = [
      { name = "DATABASE_URL", valueFrom = aws_secretsmanager_secret.db_url.arn }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:${var.app_port}/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.environment == "production" ? 2 : 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.app.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.project
    container_port   = var.app_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [task_definition]  # Managed by CI/CD
  }
}
```

### Load Balancer

```hcl
resource "aws_lb" "app" {
  name               = "${var.project}-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "app" {
  name        = "${var.project}-${var.environment}"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health/ready"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
```

---

## Deploy Target: GCP Cloud Run

```hcl
resource "google_cloud_run_v2_service" "app" {
  name     = "${var.project}-${var.environment}"
  location = var.region

  template {
    scaling {
      min_instance_count = var.environment == "production" ? 1 : 0
      max_instance_count = var.environment == "production" ? 20 : 5
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.gcp_project}/${var.project}/${var.project}:latest"

      ports { container_port = var.app_port }

      env { name = "NODE_ENV"; value = var.environment }
      env { name = "LOG_LEVEL"; value = var.environment == "production" ? "info" : "debug" }
      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_url.secret_id
            version = "latest"
          }
        }
      }

      resources {
        limits = {
          cpu    = "1"
          memory = var.environment == "production" ? "1Gi" : "512Mi"
        }
      }

      startup_probe {
        http_get { path = "/health" }
        initial_delay_seconds = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      liveness_probe {
        http_get { path = "/health" }
        period_seconds = 30
      }
    }
  }

  traffic { percent = 100; type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST" }

  lifecycle {
    ignore_changes = [template[0].containers[0].image]  # Managed by CI/CD
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  count    = var.allow_unauthenticated ? 1 : 0
  location = google_cloud_run_v2_service.app.location
  service  = google_cloud_run_v2_service.app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
```

---

## Database: PostgreSQL

### AWS RDS

```hcl
resource "aws_db_instance" "main" {
  identifier     = "${var.project}-${var.environment}"
  engine         = "postgres"
  engine_version = "{DB_VERSION}"
  instance_class = var.environment == "production" ? "db.t3.medium" : "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = var.environment == "production" ? 100 : 50
  storage_encrypted     = true

  db_name  = replace(var.project, "-", "_")
  username = "app"
  password = random_password.db.result

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = var.environment == "production" ? 7 : 1
  skip_final_snapshot     = var.environment != "production"
  deletion_protection     = var.environment == "production"

  performance_insights_enabled = var.environment == "production"
}

resource "aws_secretsmanager_secret" "db_url" {
  name = "${var.project}/${var.environment}/database-url"
}

resource "aws_secretsmanager_secret_version" "db_url" {
  secret_id     = aws_secretsmanager_secret.db_url.id
  secret_string = "postgresql://${aws_db_instance.main.username}:${random_password.db.result}@${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
}

resource "random_password" "db" {
  length  = 32
  special = false
}
```

### GCP Cloud SQL

```hcl
resource "google_sql_database_instance" "main" {
  name             = "${var.project}-${var.environment}"
  database_version = "POSTGRES_{DB_MAJOR_VERSION}"
  region           = var.region

  settings {
    tier              = var.environment == "production" ? "db-custom-2-4096" : "db-f1-micro"
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.environment == "production"
    }

    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.main.id
    }
  }

  deletion_protection = var.environment == "production"
}

resource "google_sql_database" "app" {
  name     = replace(var.project, "-", "_")
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app" {
  name     = "app"
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}

resource "google_secret_manager_secret" "db_url" {
  secret_id = "${var.project}-${var.environment}-database-url"
  replication { auto {} }
}

resource "google_secret_manager_secret_version" "db_url" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = "postgresql://app:${random_password.db.result}@${google_sql_database_instance.main.private_ip_address}/${google_sql_database.app.name}"
}
```

---

## Monitoring (from design/operations.md)

### AWS CloudWatch

```hcl
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = var.environment == "production" ? 30 : 7
}

resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "${var.project}-${var.environment}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = var.environment == "production" ? 10 : 50

  dimensions = {
    TargetGroup  = aws_lb_target_group.app.arn_suffix
    LoadBalancer = aws_lb.app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "${var.project}-${var.environment}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  extended_statistic  = "p99"
  threshold           = 2  # seconds

  dimensions = {
    TargetGroup  = aws_lb_target_group.app.arn_suffix
    LoadBalancer = aws_lb.app.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.environment}-alerts"
}
```

### GCP Cloud Monitoring

```hcl
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "${var.project}-${var.environment} High Error Rate"
  combiner     = "OR"

  conditions {
    display_name = "5xx error rate"
    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.environment == "production" ? 10 : 50
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}
```

---

## Outputs

```hcl
output "service_url" {
  value = var.deploy_target == "cloud-run" ? google_cloud_run_v2_service.app.uri : "https://${aws_lb.app.dns_name}"
}

output "database_host" {
  value     = var.cloud == "aws" ? aws_db_instance.main.endpoint : google_sql_database_instance.main.private_ip_address
  sensitive = true
}

output "log_group" {
  value = var.cloud == "aws" ? aws_cloudwatch_log_group.app.name : null
}
```

---

## Environment Variables (tfvars)

```hcl
# environments/dev.tfvars
environment      = "dev"
region           = "us-east-1"
project          = "{SERVICE}"
app_port         = 3000
certificate_arn  = "arn:aws:acm:..."  # If using HTTPS

# environments/production.tfvars
environment      = "production"
region           = "us-east-1"
project          = "{SERVICE}"
app_port         = 3000
certificate_arn  = "arn:aws:acm:..."
```

---

## Usage Commands

```bash
# Initialize (first time)
cd infra && terraform init

# Plan changes for dev
terraform plan -var-file=environments/dev.tfvars

# Apply to dev
terraform apply -var-file=environments/dev.tfvars

# Apply to production (with extra confirmation)
terraform plan -var-file=environments/production.tfvars -out=plan.out
terraform apply plan.out

# Destroy dev (cleanup)
terraform destroy -var-file=environments/dev.tfvars
```
