resource "helm_release" "metrics_server" {
  name             = "metrics-server"
  namespace        = var.namespace
  create_namespace = false

  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"

  timeout = var.helm_timeout

  set = [
    {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
  ]
}


# Metrics Server collects CPU and memory statistics from every node. 
# Every EKS node runs a process called: kubelet
# The kubelet exposes metrics over HTTPS.
# Metrics Server connects to: https://<node-ip>:10250 to collect: CPU, Memory, Pod metrics