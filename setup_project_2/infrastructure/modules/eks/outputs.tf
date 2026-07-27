output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  value = aws_iam_openid_connect_provider.cluster.url
}

output "node_security_group_id" {
  value = aws_security_group.nodes.id
}

# Managed node groups (with no custom launch template) use the security group
# that EKS creates automatically for the cluster, not aws_security_group.nodes
# above. Other modules (e.g. RDS) that need to allow traffic from the worker
# nodes must reference this security group instead.
output "cluster_security_group_id" {
  value = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}