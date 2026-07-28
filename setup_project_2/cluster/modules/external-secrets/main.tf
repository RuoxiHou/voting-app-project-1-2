resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set = [
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "external-secrets"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = var.external_secrets_role_arn
    }
  ]

  timeout = var.helm_timeout
}

# This installs External Secrets Operator, which runs inside Kubernetes and syncs secrets from AWS Secrets Manager into Kubernetes Secret objects. 

resource "kubernetes_manifest" "aws_secretsmanager_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"

    metadata = {
      name = "aws-secretsmanager"
    }

    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.aws_region

          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.external_secrets
  ]
}