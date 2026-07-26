variable "gateway_name" {
  description = "Gateway name"
  type        = string
  default     = "public-gateway"
}

variable "gateway_namespace" {
  description = "Gateway namespace"
  type        = string
  default     = "voting-app"
}

variable "gateway_class_name" {
  description = "GatewayClass name"
  type        = string
  default     = "alb"
}
