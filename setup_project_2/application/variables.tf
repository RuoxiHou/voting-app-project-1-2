variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "state_bucket" {
  description = "Terraform state bucket"
  type        = string
}

variable "infrastructure_state_key" {
  description = "S3 key for infrastructure state"
  type        = string
}

variable "cluster_state_key" {
  description = "S3 key for cluster state"
  type        = string
}

variable "student_name" {
  description = "Student name used in DNS hostnames"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate used by the ALB ingress for HTTPS"
  type        = string
  default     = ""
}
