resource "kubernetes_cluster_role" "metrics" {
  metadata {
    name   = "kube-state-metrics"
    labels = local.metadata_labels
  }

  rule {
    api_groups = [""]
    verbs      = ["list", "watch"]
    resources  = [
      "configmaps", "secrets", "nodes", "pods", "services", "serviceaccounts", "resourcequotas",
      "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints"
    ]
  }

  rule {
    api_groups = ["apps"]
    verbs      = ["list", "watch"]
    resources  = ["statefulsets", "daemonsets", "deployments", "replicasets"]
  }

  rule {
    api_groups = ["batch"]
    verbs      = ["list", "watch"]
    resources  = ["cronjobs", "jobs"]
  }

  rule {
    api_groups = ["autoscaling"]
    verbs      = ["list", "watch"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    api_groups = ["authentication.k8s.io"]
    verbs      = ["create"]
    resources  = ["tokenreviews"]
  }

  rule {
    api_groups = ["policy"]
    verbs      = ["list", "watch"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["certificatesigningrequests"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["storageclasses", "volumeattachments"]
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["networkpolicies", "ingresses"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["leases"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    verbs      = ["list", "watch"]
    resources  = ["clusterrolebindings", "clusterroles", "rolebindings", "roles"]
  }
}

resource "kubernetes_service_account" "metrics" {
  automount_service_account_token = false
  metadata {
    name      = "kube-state-metrics"
    namespace = "kube-system"
    labels    = local.metadata_labels
  }
}

resource "kubernetes_cluster_role_binding" "metrics" {
  metadata {
    name   = "kube-state-metrics"
    labels = local.metadata_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.metrics.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.metrics.metadata.0.name
    namespace = "kube-system"
  }
}
