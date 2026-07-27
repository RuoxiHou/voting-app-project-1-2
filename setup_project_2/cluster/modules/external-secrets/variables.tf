variable "external_secrets_role_arn" {
  type        = string
  description = "IAM role ARN used by External Secrets Operator via IRSA"
}

variable "aws_region" {
  type        = string
  description = "AWS region where Secrets Manager is used"
}

variable "namespace" {
  type        = string
  description = "Namespace to install External Secrets Operator into"
  default     = "external-secrets"
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}