module "external_secrets" {
  source = "./modules/external-secrets"

  aws_region = var.aws_region

  external_secrets_role_arn = data.terraform_remote_state.infrastructure.outputs.external_secrets_role_arn

  depends_on = [
    module.metrics_server
  ]
}

module "metrics_server" {
  source = "./modules/metrics-server"

  metrics_server_chart_version = var.metrics_server_chart_version
}

module "aws_load_balancer_controller" {
  source = "./modules/aws-load-balancer-controller"

  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name

  aws_region = var.aws_region

  vpc_id = data.terraform_remote_state.infrastructure.outputs.vpc_id

  alb_controller_role_arn = data.terraform_remote_state.infrastructure.outputs.alb_controller_role_arn

  aws_load_balancer_controller_chart_version = var.aws_load_balancer_controller_chart_version

  depends_on = [
    module.external_secrets,
    module.gateway_api
  ]
} # The controller attempts to detect Gateway CRDs and enables the relevant Gateway controllers when those CRDs are present.

module "gateway_api" {
  source = "./modules/gateway-api"
}

module "cluster_autoscaler" {
  source = "./modules/cluster-autoscaler"

  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name

  aws_region = var.aws_region

  cluster_autoscaler_role_arn = data.terraform_remote_state.infrastructure.outputs.cluster_autoscaler_role_arn

  cluster_autoscaler_chart_version = var.cluster_autoscaler_chart_version

  depends_on = [
    module.metrics_server,
    module.gateway_api,
    module.aws_load_balancer_controller
  ]
}

module "keda" {
  source = "./modules/keda"

  keda_chart_version = var.keda_chart_version

  depends_on = [
    module.metrics_server,
    module.cluster_autoscaler
  ]
}

module "external_dns" {
  source = "./modules/external-dns"

  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  aws_region   = var.aws_region
  domain_name  = data.terraform_remote_state.infrastructure.outputs.public_zone_name

  external_dns_role_arn = data.terraform_remote_state.infrastructure.outputs.externaldns_role_arn

  external_dns_chart_version = var.external_dns_chart_version

  depends_on = [
    module.aws_load_balancer_controller,
    module.gateway_api
  ]
}

module "cert_manager" {
  source = "./modules/cert-manager"

  cert_manager_role_arn = data.terraform_remote_state.infrastructure.outputs.cert_manager_role_arn

  cert_manager_chart_version = var.cert_manager_chart_version

  depends_on = [
    module.aws_load_balancer_controller,
    module.external_dns
  ]
}

module "gateway" {
  source = "./modules/gateway"

  gateway_name       = var.gateway_name
  gateway_namespace  = var.gateway_namespace
  gateway_class_name = var.gateway_class_name

  depends_on = [
    module.aws_load_balancer_controller
  ]
}