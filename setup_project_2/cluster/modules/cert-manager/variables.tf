variable "cert_manager_role_arn" {
  type        = string
  description = "IAM role ARN for cert-manager IRSA"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Helm chart version for cert-manager"
  default     = "1.21.0"
}

variable "namespace" {
  type        = string
  description = "Namespace to install cert-manager into"
  default     = "cert-manager"
}

variable "replica_count" {
  type        = number
  description = "Number of cert-manager controller replicas"
  default     = 2
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}