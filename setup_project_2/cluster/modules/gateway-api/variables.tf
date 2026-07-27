variable "gateway_api_version" {
  type        = string
  description = "Gateway API CRD version"
  default     = "v1.6.1"
}

variable "aws_lbc_gateway_crds_ref" {
  type        = string
  description = "Git ref for AWS Load Balancer Controller Gateway API CRDs"
  default     = "main"
}

variable "gateway_class_name" {
  type        = string
  description = "GatewayClass name for AWS ALB Gateway API"
  default     = "alb"
}
