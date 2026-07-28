# VPC
########################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_eks_subnet_ids" {
  value = module.vpc.private_eks_subnet_ids
}

output "private_rds_subnet_ids" {
  value = module.vpc.private_rds_subnet_ids
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

# EKS
########################################

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider_url
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

# RDS
########################################

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "rds_port" {
  value = module.rds.rds_port
}

output "rds_identifier" {
  value = module.rds.rds_identifier
}

output "db_secret_arn" {
  value = module.secretsmanager.db_secret_arn
}

output "db_secret_name" {
  value = module.secretsmanager.db_secret_name
}
# Route53
########################################
output "public_zone_arn" {
  value = module.route53.public_zone_arn
}

output "public_zone_name" {
  value = module.route53.public_zone_name
}

output "public_zone_id" {
  value = module.route53.public_zone_id
}

# IAM
########################################

output "alb_controller_role_arn" {
  value = module.iam.alb_controller_role_arn
}

output "external_secrets_role_arn" {
  value = module.iam.external_secrets_role_arn
}

output "cluster_autoscaler_role_arn" {
  value = module.iam.cluster_autoscaler_role_arn
}

output "externaldns_role_arn" {
  value = module.iam.externaldns_role_arn
}

output "cert_manager_role_arn" {
  value = module.iam.cert_manager_role_arn
}
