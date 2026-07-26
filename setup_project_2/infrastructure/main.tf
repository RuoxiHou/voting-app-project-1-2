module "vpc" {
  source = "./modules/vpc"

  student_name     = var.student_name
  project_name     = var.project_name
  vpc_cidr_block   = var.vpc_cidr_block
  public_subnet_a  = var.public_subnet_a
  public_subnet_b  = var.public_subnet_b
  private_subnet_a = var.private_subnet_a
  private_subnet_b = var.private_subnet_b
  private_subnet_c = var.private_subnet_c
  private_subnet_d = var.private_subnet_d
  az_1             = var.az_1
  az_2             = var.az_2
  eks_cluster_name = var.eks_cluster_name
}

module "eks" {
  source = "./modules/eks"

  student_name           = var.student_name
  project_name           = var.project_name
  eks_cluster_name       = var.eks_cluster_name
  eks_version            = var.eks_version
  vpc_id                 = module.vpc.vpc_id
  private_eks_subnet_ids = module.vpc.private_eks_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
}

module "secretsmanager" {
  source = "./modules/secretsmanager"

  student_name = var.student_name
  project_name = var.project_name

  db_username = var.db_username
  db_name     = var.db_name
}

module "rds" {
  source = "./modules/rds"

  student_name               = var.student_name
  project_name               = var.project_name
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr_block             = var.vpc_cidr_block
  private_rds_subnet_ids     = module.vpc.private_rds_subnet_ids
  eks_node_security_group_id = module.eks.node_security_group_id

  db_identifier = var.db_identifier
  db_name       = var.db_name
  db_username   = var.db_username
  db_password   = module.secretsmanager.db_password

  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_multi_az          = var.db_multi_az
}

module "route53" {
  source = "./modules/route53"

  hosted_zone_id = var.hosted_zone_id
  domain_name    = var.domain_name

  student_name = var.student_name
  project_name = var.project_name
}

module "iam" {
  source = "./modules/iam"

  student_name = var.student_name
  project_name = var.project_name

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  public_zone_arn = module.route53.public_zone_arn
}
