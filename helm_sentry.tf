
# ------------------------------------------------------------------------------
# Sentry Install
# ------------------------------------------------------------------------------

# chart = "${path.module}/helm_sentry/"
# When PR is merged: https://github.com/sentry-kubernetes/charts/pull/558,
resource "helm_release" "sentry" {
  name              = "sentry"
  chart             = "sentry"
  repository        = "https://sentry-kubernetes.github.io/charts"
  version           = var.sentry_helm_chart_version
  timeout           = 900
  wait              = true
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
        tags                    = "environment=${var.env}",

        postgres_db_host  = "${var.db_host}",
        postgres_db_port  = "${var.db_port}",
        postgres_db_name  = "${var.db_name}",
        postgres_username = "${var.db_user}",
        postgres_password = "${var.db_pass}",

        smtp_enable   = var.smtp_enable
        smtp_host     = "${var.smtp_host}",
        smtp_username = "${var.smtp_username}",
        smtp_password = "${var.smtp_password}",
        dns_name      = "${local.sentry_dns_name}",

        slack_enable                = var.slack_enable
        sentry_slack_client_id      = "${var.sentry_slack_client_id}",
        sentry_slack_client_secret  = "${var.sentry_slack_client_secret}",
        sentry_slack_signing_secret = "${var.sentry_slack_signing_secret}",
        existing_secret_name        = "${kubernetes_secret_v1.sentry_secrets.metadata[0].name}",
      }
    )
  ]
}

# ------------------------------------------------------------------------------
# Prometheus Install
# ------------------------------------------------------------------------------

resource "kubernetes_namespace" "prometheus" {
  count = var.create_prometheus_server == true ? 1 : 0
  metadata {
    name = var.prometheus_namespace
  }
}

resource "helm_release" "prometheus_install" {
  count             = var.create_prometheus_server == true ? 1 : 0
  name              = "prometheus-for-amp"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "prometheus"
  namespace         = var.prometheus_namespace
  timeout           = 600
  wait              = false
  dependency_update = true
  values = [
    templatefile(
      "${path.module}/templates/prometheus_for_amp_values.yaml",
      {
        region    = var.aws_region
        name      = var.service_account_name
        arn       = aws_iam_role.sentry_eks_amp_role[0].arn
        workspace = var.sentry_amp_workspace_id
      }
    )
  ]

  depends_on = [
    kubernetes_namespace.prometheus
  ]

  lifecycle {
    precondition {
      condition     = var.sentry_amp_workspace_id != null
      error_message = "The var.sentry_amp_workspace_id cannot be NULL when var.create_prometheus_server is set to TRUE."
    }
  }

}
