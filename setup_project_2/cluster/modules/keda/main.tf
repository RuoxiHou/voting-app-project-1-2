resource "helm_release" "keda" {
  name             = "keda"
  namespace        = "keda"
  create_namespace = true

  repository = "https://kedacore.github.io/charts"
  chart      = "keda"

  version = var.keda_chart_version

  set = [
    {
      name  = "operator.replicaCount"
      value = "2"
    }
  ]
  
  timeout = 600
}