variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "cluster_autoscaler_role_arn" {
  type        = string
  description = "IAM role ARN for Cluster Autoscaler IRSA"
}

variable "cluster_autoscaler_chart_version" {
  type        = string
  description = "Helm chart version for Cluster Autoscaler"
  default     = "9.59.0"
}

variable "namespace" {
  type        = string
  description = "Namespace to install Cluster Autoscaler into"
  default     = "kube-system"
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}
