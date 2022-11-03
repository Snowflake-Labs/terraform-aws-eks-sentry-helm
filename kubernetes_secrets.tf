resource "kubernetes_secret_v1" "sentry_secrets" {
  metadata {
    name = "sentry-secrets"
  }

  data = {
    sentry_secret_key = var.sentry_secret_key
  }
}
