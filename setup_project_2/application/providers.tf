terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.56"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.2"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infrastructure.outputs.cluster_certificate_authority_data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"

    args = [
      "eks",
      "get-token",
      "--region",
      var.aws_region,
      "--cluster-name",
      data.terraform_remote_state.infrastructure.outputs.cluster_name,
      "--output",
      "json"
    ]
  }
}

provider "helm" {
  kubernetes = {
    host = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.infrastructure.outputs.cluster_certificate_authority_data
    )

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"

      args = [
        "eks",
        "get-token",
        "--region",
        var.aws_region,
        "--cluster-name",
        data.terraform_remote_state.infrastructure.outputs.cluster_name,
        "--output",
        "json"
      ]
    }
  }
}