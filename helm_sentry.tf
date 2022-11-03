
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
        tags                    = "environment=${var.env}",

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
        existing_secret_name        = "${kubernetes_secret_v1.sentry_secrets.metadata.name}",
      }
    )
  ]
}

# ------------------------------------------------------------------------------
# Monitoring Configuration
# ------------------------------------------------------------------------------

data "aws_iam_policy_document" "sentry_remote_write_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.grafana_namespace}:${var.service_account_name}"
      ]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.prometheus_namespace}:${var.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "sentry_eks_amp_role" {
  name               = var.service_account_iam_role_name
  description        = var.service_account_iam_role_description
  assume_role_policy = data.aws_iam_policy_document.sentry_remote_write_assume.json
}

resource "aws_iam_policy" "sentry_amp_write" {
  name        = var.service_account_iam_policy_name
  description = "Permissions to write to all AMP workspaces"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "aps:RemoteWrite",
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sentry_amp_write" {
  role       = aws_iam_role.sentry_eks_amp_role.name
  policy_arn = aws_iam_policy.sentry_amp_write.arn
}

resource "kubernetes_namespace" "prometheus" {
  count = var.create_prometheus_server == true ? 1 : 0
  metadata {
    name = var.prometheus_namespace
  }
}

resource "helm_release" "prometheus_install" {
  count = var.create_prometheus_server == true ? 1 : 0

  name      = "prometheus-for-amp"
  namespace = var.prometheus_namespace

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  timeout           = 600
  wait              = false
  dependency_update = true

  values = [
    templatefile(
      "${path.module}/templates/prometheus_for_amp_values.yaml",
      {
        region    = var.aws_region
        name      = var.service_account_name
        arn       = aws_iam_role.sentry_eks_amp_role.arn
        workspace = var.sentry_amp_workspace_id
      }
    )
  ]

  depends_on = [
    kubernetes_namespace.prometheus,
  ]

  lifecycle {
    ignore_changes = all
  }
}
