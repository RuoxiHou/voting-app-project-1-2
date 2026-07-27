variable "keda_chart_version" {
  type        = string
  description = "Helm chart version for KEDA"
  default     = "2.20.1"
}

variable "namespace" {
  type        = string
  description = "Namespace to install KEDA into"
  default     = "keda"
}

variable "replica_count" {
  type        = number
  description = "Number of KEDA operator replicas"
  default     = 2
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}