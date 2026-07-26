locals {
  name_prefix = "${var.project_name}-${var.student_name}"
}

resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "postgres" {
  name        = "${local.name_prefix}/rds/postgres"
  description = "PostgreSQL credentials for voting app"

  tags = {
    Name = "${local.name_prefix}-postgres-secret"
  }
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id

  secret_string = jsonencode({
    host     = var.rds_endpoint
    port     = var.rds_port
    username = var.db_username
    password = random_password.db_password.result
    database = var.db_name
  })
}