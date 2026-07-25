output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}

output "externaldns_role_arn" {
  value = try(aws_iam_role.externaldns[0].arn, null)
}

output "cert_manager_role_arn" {
  value = try(aws_iam_role.cert_manager[0].arn, null)
}

output "external_secrets_role_arn" {
  value = aws_iam_role.external_secrets.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}
