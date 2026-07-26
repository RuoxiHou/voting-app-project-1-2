resource "terraform_data" "gateway" {

  provisioner "local-exec" {
    command = <<EOT
kubectl apply -f ${path.module}/gateway.yaml
EOT
  }
}