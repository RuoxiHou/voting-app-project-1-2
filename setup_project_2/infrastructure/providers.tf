provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "voting-app-eks"
      Student   = var.student_name
      ManagedBy = "Terraform"
    }
  }
}