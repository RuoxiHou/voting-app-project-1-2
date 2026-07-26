terraform {
  backend "s3" {
    key          = "infrastructure/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}