variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume this role, in \"owner/repo\" form"
  type        = string
  default     = "RuoxiHou/voting-app-project-1-2"
}

variable "allowed_branches" {
  description = "Branches allowed to assume the role via OIDC (matches the triggers in .github/workflows)"
  type        = list(string)
  default     = ["main", "advanced"]
}

variable "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions"
  type        = string
  default     = "project2-github-actions-role"
}

variable "create_oidc_provider" {
  description = <<-EOT
    Whether to create the token.actions.githubusercontent.com OIDC provider.
    An AWS account can only have ONE provider for a given URL. Since I probably have one, I'll set this to false, and the
    existing provider will be reused instead.
  EOT
  type        = bool
  default     = false
}
