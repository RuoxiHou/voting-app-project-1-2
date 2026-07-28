resource "kubernetes_service_account_v1" "external_dns" {
  metadata {
    name      = "external-dns"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = var.external_dns_role_arn
    }

    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
}

resource "helm_release" "external_dns" {
  name      = "external-dns"
  namespace = var.namespace

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version

  set = [
    {
        name  = "provider.name"
        value = "aws"
    },
    {
        name  = "aws.region"
        value = var.aws_region
    },
    {
        name  = "policy"
        value = "sync"
    },
    {
        name  = "registry"
        value = "txt"
    },
    {
        name  = "txtOwnerId"
        value = var.cluster_name
    },
    {
        name  = "domainFilters[0]"
        value = var.domain_name
    },
    {
        name  = "serviceAccount.create"
        value = "false"
    },
    {
        name  = "serviceAccount.name"
        value = kubernetes_service_account_v1.external_dns.metadata[0].name
    },
    {
        name  = "sources[0]"
        value = "service"
    },
    {
        name  = "sources[1]"
        value = "ingress"
    }
  ]

  timeout = var.helm_timeout

  depends_on = [
    kubernetes_service_account_v1.external_dns
  ]
}