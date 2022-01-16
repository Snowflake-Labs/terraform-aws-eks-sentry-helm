resource "kubernetes_namespace" "sentry" {
  metadata {
    name = var.sentry_namespace
  }
}

resource "helm_release" "sentry" {
  name         = "sentry"
  chart        = "sentry"
  repository   = "https://sentry-kubernetes.github.io/charts"
  version      = "12.0.0"

  namespace    = kubernetes_namespace.sentry.metadata[0].name
  timeout      = 600
  wait         = false
  force_update = true

  values = [
    templatefile(
      "${path.module}/templates/sentry/values.yaml",
      {
        module_prefix = "${var.module_prefix}",

        sentry_email = "${var.sentry_email}",
        sentry_password = "${var.sentry_password}",

        sentry_dns_name = "${local.sentry_dns_name}",
        subdomain_cert_arn = "${var.subdomain_cert_arn}",
        allowed_cidr_blocks_str = "${join(",", var.allowed_cidr_blocks)}",
        private_subnet_ids_str = "${join(",", var.private_subnet_ids)}"
        postgres_db_host = "${module.sentry_rds_pg.this_rds_cluster_endpoint}"
        postgres_db_name = "${local.db_name}",
        postgres_username = "${local.db_user}",
        postgres_password = "${local.db_pass}",
      }
    )
  ]

  depends_on = [helm_release.external_dns]
}
