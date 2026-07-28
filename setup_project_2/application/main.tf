resource "helm_release" "voting_app" {
  name             = "voting-app"
  namespace        = "voting-app"
  create_namespace = true

  chart = "${path.module}/helm/voting-app"

  cleanup_on_fail  = true
  dependency_update = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({

      namespace = "voting-app"

      vote = {
        replicaCount = 2
        image        = "${var.student_name}/voting-app:latest"
      }

      worker = {
        replicaCount = 2
        image        = "${var.student_name}/worker-app:latest"

        autoscaling = {
          enabled     = true
          minReplicas = 2
          maxReplicas = 10
        }
      }

      result = {
        replicaCount = 2
        image        = "${var.student_name}/result-app:latest"
      }

      redis = {
        replicaCount = 1
        image        = "redis:8-alpine"
        serviceName  = "redis"
        port         = 6379
      }

      hosts = {
        vote   = "vote-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
        result = "result-${var.student_name}.${data.terraform_remote_state.infrastructure.outputs.public_zone_name}"
      }

      ingress = {
        certificateArn = var.acm_certificate_arn
      }

      database = {
        secretName    = "voting-db"
        awsSecretName = data.terraform_remote_state.infrastructure.outputs.db_secret_name
      }
    })
  ]

  depends_on = []
}