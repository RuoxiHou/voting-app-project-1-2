variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "tfstate_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "cluster_autoscaler_chart_version" {
  description = "Helm chart version for Cluster Autoscaler"
  type        = string
  default     = "9.59.0"
}

variable "keda_chart_version" {
  description = "Helm chart version for KEDA"
  type        = string
  default     = "2.20.1"
}

variable "gateway_api_version" {
  description = "Gateway API CRD version"
  type        = string
  default     = "v1.6.1"
}

variable "aws_load_balancer_controller_chart_version" {
  description = "AWS Load Balancer Controller Helm chart version"
  type        = string
  default     = "3.4.2"
}

variable "external_dns_chart_version" {
  type        = string
  description = "Helm chart version for ExternalDNS"
  default     = "1.21.1"
}

variable "cert_manager_chart_version" {
  type        = string
  description = "Helm chart version for cert-manager"
  default     = "1.21.0"
}

variable "metrics_server_chart_version" {
  type        = string
  description = "Helm chart version for Metrics Server"
  default     = "3.13.0"
}

variable "gateway_name" {
  type    = string
  default = "public-gateway"
}

variable "gateway_namespace" {
  type    = string
  default = "voting-app"
}

variable "gateway_class_name" {
  type    = string
  default = "alb"
}