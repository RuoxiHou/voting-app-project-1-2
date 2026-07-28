output "github_actions_role_arn" {
  description = "ARN to put in the AWS_ROLE_ARN GitHub Actions secret"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  value = local.oidc_provider_arn
}
