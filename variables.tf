variable "metrics_version" {
  type        = string
  description = "The version of `kube-state-metrics` to use in this deployment."
  default     = "2.6.0"
}

locals {
  version         = var.metrics_version
  metadata_labels = {
    "app.kubernetes.io/component" = "exporter"
    "app.kubernetes.io/name"      = "kube-state-metrics"
    "app.kubernetes.io/version"   = local.version
  }
}
