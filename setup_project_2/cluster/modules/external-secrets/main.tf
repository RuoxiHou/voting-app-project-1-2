resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = "external-secrets"
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

  timeout = 600
}

# This installs External Secrets Operator, which runs inside Kubernetes and syncs secrets from AWS Secrets Manager into Kubernetes Secret objects. 
# The official docs say it runs as a deployment in the cluster and manages Kubernetes secrets from external providers through these custom resources.