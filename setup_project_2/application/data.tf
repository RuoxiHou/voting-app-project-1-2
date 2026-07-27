data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.infrastructure_state_key
    region = var.aws_region
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.cluster_state_key
    region = var.aws_region
  }
}