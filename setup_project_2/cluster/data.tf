data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "infrastructure/terraform.tfstate"
    region = var.aws_region
  }
}