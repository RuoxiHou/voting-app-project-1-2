variable "external_secrets_role_arn" {
  type        = string
  description = "IAM role ARN used by External Secrets Operator via IRSA"
}

variable "aws_region" {
  type        = string
  description = "AWS region where Secrets Manager is used"
}