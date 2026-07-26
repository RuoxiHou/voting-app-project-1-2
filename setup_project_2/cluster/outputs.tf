output "gateway_class_name" {
  value = module.gateway_api.gateway_class_name
}

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

output "gateway_name" {
  value = module.gateway.gateway_name
}

output "gateway_namespace" {
  value = module.gateway.gateway_namespace
}