output "db_secret_arn" {
  value = aws_secretsmanager_secret.postgres.arn
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.postgres.name
}