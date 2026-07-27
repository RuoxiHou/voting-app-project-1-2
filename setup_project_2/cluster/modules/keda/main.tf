resource "helm_release" "keda" {
  name             = "keda"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://kedacore.github.io/charts"
  chart      = "keda"

  version = var.keda_chart_version

  set = [
    {
      name  = "operator.replicaCount"
      value = tostring(var.replica_count)
    }
  ]
  
  timeout = var.helm_timeout
}