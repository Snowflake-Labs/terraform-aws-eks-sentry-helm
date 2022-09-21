
# chart = "${path.module}/helm_sentry/"
# When PR is merged: https://github.com/sentry-kubernetes/charts/pull/558,
resource "helm_release" "sentry" {
  name              = "sentry"
  chart             = "sentry"
  repository        = "https://sentry-kubernetes.github.io/charts"
  version           = var.sentry_helm_chart_version
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

        postgres_db_host  = "${var.db_host}",
        postgres_db_port  = "${var.db_port}",
        postgres_db_name  = "${var.db_name}",
        postgres_username = "${var.db_user}",
        postgres_password = "${var.db_pass}",

        smtp_host     = "${var.smtp_host}",
        smtp_username = "${var.smtp_username}",
        smtp_password = "${var.smtp_password}",
        dns_name      = "${local.sentry_dns_name}",

        sentry_slack_client_id      = "${var.sentry_slack_client_id}",
        sentry_slack_client_secret  = "${var.sentry_slack_client_secret}",
        sentry_slack_signing_secret = "${var.sentry_slack_signing_secret}",
      }
    )
  ]
}
