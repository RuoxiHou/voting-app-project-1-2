resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = var.cluster_autoscaler_role_arn
    }

    labels = {
      "app.kubernetes.io/name" = "cluster-autoscaler"
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name      = "cluster-autoscaler"
  namespace = var.namespace

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"

  version = var.cluster_autoscaler_chart_version

  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = var.cluster_name
    },
    {
      name  = "awsRegion"
      value = var.aws_region
    },
    {
      name  = "cloudProvider"
      value = "aws"
    },
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
    },
    {
      name  = "extraArgs.balance-similar-node-groups"
      value = "true"
    },
    {
      name  = "extraArgs.skip-nodes-with-system-pods"
      value = "false"
    },
    {
      name  = "extraArgs.scale-down-enabled"
      value = "true"
    },
    {
      name  = "extraArgs.expander"
      value = "least-waste"
    }
  ]

  timeout = var.helm_timeout

  depends_on = [
    kubernetes_service_account_v1.cluster_autoscaler
  ]
}