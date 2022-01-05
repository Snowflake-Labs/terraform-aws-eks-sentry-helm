resource "kubernetes_namespace" "sentry" {
  metadata {
    name = var.sentry_namespace
  }
}

resource "helm_release" "sentry" {
  name       = "sentryy"
  repository = "https://sentry-kubernetes.github.io/charts"
  chart      = "sentry/sentry"
  namespace  = kubernetes_namespace.sentry.metadata[0].name

  values = [
    file("${path.module}/templates/sentry/values.yaml")
  ]
}
