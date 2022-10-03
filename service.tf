resource "kubernetes_service" "metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels    = local.metadata_labels
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = local.metadata_labels["app.kubernetes.io/name"]
    }

    cluster_ip = "None"

    port {
      name        = "http-metrics"
      port        = 8080
      target_port = "http-metrics"
    }

    port {
      name        = "telemetry"
      port        = 8081
      target_port = "telemetry"
    }
  }
}
