resource "kubernetes_service_account_v1" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = var.alb_controller_role_arn
    }
  }
}

resource "kubernetes_cluster_role_v1" "aws_load_balancer_controller_secret_read" {
  metadata {
    name = "aws-load-balancer-controller-secret-read"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "aws_load_balancer_controller_secret_read" {
  metadata {
    name = "aws-load-balancer-controller-secret-read"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.aws_load_balancer_controller_secret_read.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
    namespace = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].namespace
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = var.namespace

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version = var.aws_load_balancer_controller_chart_version

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
    },
    {
      name  = "defaultTargetType"
      value = "ip"
    }
  ]

  timeout = var.helm_timeout

  depends_on = [
    kubernetes_service_account_v1.aws_load_balancer_controller
  ]
}