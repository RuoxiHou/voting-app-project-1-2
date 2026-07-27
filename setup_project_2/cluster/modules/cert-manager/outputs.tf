output "release_name" {
  value = helm_release.cert_manager.name
}

output "namespace" {
  value = helm_release.cert_manager.namespace
}

output "service_account_name" {
  value = kubernetes_service_account_v1.cert_manager.metadata[0].name
}

output "service_account_role_arn" {
  value = var.cert_manager_role_arn
}