output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "rds_identifier" {
  value = aws_db_instance.postgres.identifier
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "rds_availability_zone" {
  value = aws_db_instance.postgres.availability_zone
}

output "rds_arn" {
  value = aws_db_instance.postgres.arn
}