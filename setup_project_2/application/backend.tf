terraform {
  backend "s3" {
    key          = "application/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}