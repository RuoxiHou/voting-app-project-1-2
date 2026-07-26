resource "kubernetes_namespace_v1" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_service_account_v1" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = var.cert_manager_role_arn
    }
  }
  depends_on = [
    kubernetes_namespace_v1.cert_manager
  ]
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version

  set = [
    {
        name  = "crds.enabled"
        value = "true"
    },
    {
        name  = "serviceAccount.create"
        value = "false"
    },
    {
        name  = "serviceAccount.name"
        value = kubernetes_service_account_v1.cert_manager.metadata[0].name
    },
    {
        name  = "replicaCount"
        value = "2"
    }
  ]

  timeout = 600

  depends_on = [
    kubernetes_service_account_v1.cert_manager
  ]
}