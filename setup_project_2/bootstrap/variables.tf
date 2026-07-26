variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "student_name" {
  type = string
  default = "ruoxi"
}

variable "project_name" {
  type = string
  default = "project2"
}