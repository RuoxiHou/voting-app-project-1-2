variable "cert_manager_role_arn" {
  type        = string
  description = "IAM role ARN for cert-manager IRSA"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Helm chart version for cert-manager"
  default     = "1.21.0"
}