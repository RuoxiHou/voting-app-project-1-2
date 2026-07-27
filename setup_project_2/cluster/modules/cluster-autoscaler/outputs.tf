output "release_name" {
  value = helm_release.cluster_autoscaler.name
}

output "namespace" {
  value = helm_release.cluster_autoscaler.namespace
}

output "service_account_name" {
  value = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
}

output "service_account_arn" {
  value = var.cluster_autoscaler_role_arn
}