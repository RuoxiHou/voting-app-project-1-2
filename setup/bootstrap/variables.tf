variable "bucket_name" {
    description = "S3 bucket that stores the tfstate and lock table"
    type = string
    default = "tfstate-bucket-test-ruoxi"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
}