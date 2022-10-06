resource "kubernetes_deployment" "metrics" {
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels    = local.metadata_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = local.metadata_labels["app.kubernetes.io/name"]
      }
    }

    template {
      metadata {
        labels = local.metadata_labels
      }

      spec {
        service_account_name            = kubernetes_service_account.metrics.metadata.0.name
        automount_service_account_token = true

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        container {
          name  = "kube-state-metrics"
          image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v${local.version}"

          port {
            name           = "http-metrics"
            container_port = 8080
          }

          port {
            name           = "telemetry"
            container_port = 8081
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8081
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
          }

          security_context {
            run_as_user                = 65534
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }
        }
      }
    }
  }
}
