variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "domain_name" {
  type        = string
  description = "Route53 domain managed by ExternalDNS"
}

variable "external_dns_role_arn" {
  type        = string
  description = "IAM role ARN for ExternalDNS IRSA"
}

variable "external_dns_chart_version" {
  type        = string
  description = "Helm chart version for ExternalDNS"
  default     = "1.18.0"
}

variable "namespace" {
  type        = string
  description = "Namespace to install ExternalDNS into"
  default     = "kube-system"
}

variable "helm_timeout" {
  type        = number
  description = "Timeout (seconds) for the helm_release to become ready"
  default     = 600
}