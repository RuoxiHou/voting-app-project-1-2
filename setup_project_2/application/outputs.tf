output "helm_release_name" {
  description = "Voting app Helm release name"
  value       = helm_release.voting_app.name
}

output "helm_release_namespace" {
  description = "Namespace where the voting app is deployed"
  value       = helm_release.voting_app.namespace
}

output "vote_hostname" {
  description = "Vote application hostname"
  value = "vote-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
}

output "result_hostname" {
  description = "Result application hostname"
  value = "result-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
}

output "vote_url" {
  value = "https://vote-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
}

output "result_url" {
  value = "https://result-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
}
