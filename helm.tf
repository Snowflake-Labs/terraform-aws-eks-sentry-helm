resource "kubernetes_namespace" "sentry" {
  metadata {
    name = var.sentry_namespace
  }
}

resource "helm_release" "sentry" {
  name       = "sentry"
  repository = "https://sentry-kubernetes.github.io/charts"
  chart      = "sentry"
  version    = "12.0.0"
  namespace  = kubernetes_namespace.sentry.metadata[0].name
  timeout    = 600

#   values = [
#     file("${path.module}/templates/sentry/values.yaml")
#   ]
}
