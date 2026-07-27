provider "aws" {
  region = var.aws_region
}

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
# EKS Authentication
data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

# Kubernetes Provider
provider "kubernetes" {
  host = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infrastructure.outputs.cluster_certificate_authority_data
  )

  token = data.aws_eks_cluster_auth.cluster.token
}

# Helm Provider
provider "helm" {
  kubernetes = {
    host = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.infrastructure.outputs.cluster_certificate_authority_data
    )

    token = data.aws_eks_cluster_auth.cluster.token
  }
}