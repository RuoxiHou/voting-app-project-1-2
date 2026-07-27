output "release_name" {
  value = helm_release.external_dns.name
}

output "namespace" {
  value = helm_release.external_dns.namespace
}

output "service_account_name" {
  value = kubernetes_service_account_v1.external_dns.metadata[0].name
}