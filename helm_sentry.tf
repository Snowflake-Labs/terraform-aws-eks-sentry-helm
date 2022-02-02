data "kubernetes_service" "lb_controller_webhook_service" {
  metadata {
    name      = "aws-load-balancer-webhook-service"
    namespace = "kube-system"
  }
}

data "kubernetes_service" "external_dns_service" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
  }
}

resource "helm_release" "sentry" {
  name       = "sentry"
  chart      = "sentry"
  repository = "https://sentry-kubernetes.github.io/charts"
  version    = "13.0.1"

  timeout           = 600
  wait              = false
  dependency_update = true

  values = [
    templatefile(
      "${path.module}/templates/sentry_values.yaml",
      {
        module_prefix             = "${var.module_prefix}",
        sentry_root_user_email    = "${var.sentry_root_user_email}",
        sentry_root_user_password = "${var.sentry_root_user_password}",

        sentry_dns_name         = "${local.sentry_dns_name}",
        subdomain_cert_arn      = "${var.subdomain_cert_arn}",
        allowed_cidr_blocks_str = "${join(",", var.allowed_cidr_blocks)}",
        private_subnet_ids_str  = "${join(",", var.private_subnet_ids)}",
        public_subnet_ids_str   = "${join(",", var.public_subnet_ids)}",
        tags                    = "environment=${var.env}"

        postgres_db_host  = "${module.sentry_rds_pg.this_rds_cluster_endpoint}",
        postgres_db_name  = "${var.db_name}",
        postgres_username = "${var.db_user}",
        postgres_password = "${var.db_pass}",
        smtp_host         = "${var.smtp_host}",
        smtp_username     = "${var.smtp_username}",
        smtp_password     = "${var.smtp_password}",
        dns_name          = "${local.sentry_dns_name}",
      }
    )
  ]

  depends_on = [
    kubernetes_service.lb_controller_webhook_service,
    kubernetes_service.external_dns_service
  ]
}
