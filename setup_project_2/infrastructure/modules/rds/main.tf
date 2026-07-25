locals {
  name_prefix = "${var.project_name}-${var.student_name}"
}

# Security Group for PostgreSQL
resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow PostgreSQL access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"

    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      var.eks_node_security_group_id
    ]
  }

  egress {
    description = "Allow outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name = "${local.name_prefix}-postgres-subnet-group"

  subnet_ids = var.private_rds_subnet_ids

  tags = {
    Name = "${local.name_prefix}-postgres-subnet-group"
  }
}

# Parameter Group (RDS AWS manages the database server, so the configuration of PostgreSQL is through a parameter group instead of postgresql.conf)
resource "aws_db_parameter_group" "postgres" {
  name   = "${local.name_prefix}-postgres-params"
  family = "postgres18"
  lifecycle {
    create_before_destroy = true
  } # This helps prevent issues during major version upgrades where a parameter group family changes.

  parameter {
    name  = "log_connections"
    value = "1"
  } # Logs every successful client connection.

  parameter {
    name  = "log_disconnections"
    value = "1"
  } # Logs every client disconnect.

  tags = {
    Name = "${local.name_prefix}-postgres-params"
  }
}

# RDS PostgreSQL Multi-AZ
resource "aws_db_instance" "postgres" {
  identifier = var.db_identifier

  engine         = "postgres"
  engine_version = var.db_engine_version

  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100

  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  port = 5432

  publicly_accessible = false

  multi_az = var.db_multi_az

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  parameter_group_name   = aws_db_parameter_group.postgres.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  backup_window           = "02:00-03:00"

  maintenance_window = "sun:03:00-sun:04:00"

  auto_minor_version_upgrade = true

  deletion_protection = false # For production, it should be true as I need to delete the cluster afterwards.
  skip_final_snapshot = true # For production, it should be false as I need to delete the cluster afterwards.

  apply_immediately = true

  enabled_cloudwatch_logs_exports = [
    "postgresql"
  ] # Allow the Connection logs, Query logs, Startup events and Failover events to be seen in CloudWatch

  tags = {
    Name = "${local.name_prefix}-postgres"
  }
}