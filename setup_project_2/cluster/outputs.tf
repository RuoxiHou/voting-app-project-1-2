output "metrics_server_release" {
  value = module.metrics_server.release_name
}

output "external_secrets_release" {
  value = module.external_secrets.release_name
}

output "aws_load_balancer_controller_release" {
  value = module.aws_load_balancer_controller.release_name
}

output "cluster_autoscaler_release" {
  value = module.cluster_autoscaler.release_name
}

output "keda_release" {
  value = module.keda.release_name
}