output "release_name" {
  value = helm_release.aws_load_balancer_controller.name
}

output "namespace" {
  value = helm_release.aws_load_balancer_controller.namespace
}

output "service_account_name" {
  value = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
}