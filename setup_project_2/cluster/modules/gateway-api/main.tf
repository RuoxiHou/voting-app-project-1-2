# This module only installs the required Gateway API CRDs, the AWS Load Balancer Controller Gateway-specific CRDs, and creates the GatewayClass for ALB.
resource "terraform_data" "gateway_api_standard_crds" {
  triggers_replace = {
    gateway_api_version = var.gateway_api_version
  }

  provisioner "local-exec" {
    command = "kubectl apply --server-side=true -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml"
  }
}

resource "terraform_data" "aws_lbc_gateway_crds" {
  triggers_replace = {
    aws_lbc_gateway_crds_ref = var.aws_lbc_gateway_crds_ref
  }

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${var.aws_lbc_gateway_crds_ref}/config/crd/gateway/gateway-crds.yaml"
  }

  depends_on = [
    terraform_data.gateway_api_standard_crds
  ]
}

resource "terraform_data" "alb_gateway_class" {
  triggers_replace = {
    gateway_class_name = var.gateway_class_name
  }

  provisioner "local-exec" {
    command = <<EOT
kubectl apply -f - <<'YAML'
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: ${var.gateway_class_name}
spec:
  controllerName: gateway.k8s.aws/alb
YAML
EOT
  }

  depends_on = [
    terraform_data.aws_lbc_gateway_crds
  ]
}