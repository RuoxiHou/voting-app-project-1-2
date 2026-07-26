variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster runs"
}

variable "alb_controller_role_arn" {
  type        = string
  description = "IAM role ARN for AWS Load Balancer Controller IRSA"
}

variable "aws_load_balancer_controller_chart_version" {
  type        = string
  description = "ALB Controller Helm chart version"
}