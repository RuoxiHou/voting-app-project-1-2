output "release_name" {
  value = helm_release.keda.name
}

output "namespace" {
  value = helm_release.keda.namespace
}