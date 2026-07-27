variable "metrics_server_chart_version" {
  type        = string
  description = "Helm chart version for Metrics Server"
  default     = "3.13.1"
}

variable "namespace" {
  type        = string
  description = "Namespace to install Metrics Server into"
  default     = "kube-system"
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}