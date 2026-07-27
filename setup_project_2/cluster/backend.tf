# NOTE: Terraform backend blocks cannot reference variables or outputs - the
# region below must stay a literal and must match var.aws_region used
# elsewhere in this configuration.
terraform {
  backend "s3" {
    key          = "cluster/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}