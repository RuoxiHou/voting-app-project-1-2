terraform {
  backend "s3" {
    key          = "cluster/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true
  }
}