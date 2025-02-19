resource "kubernetes_secret_v1" "sentry_secrets" {
  metadata {
    name      = "sentry-secrets"
    namespace = var.sentry_kubernetes_namespace
  }

  data = {
    sentry_secret_key = "${var.sentry_secret_key}"
  }

  depends_on = [
    kubernetes_namespace.sentry
  ]
}
