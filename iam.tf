# ------------------------------------------------------------------------------
# IAM Resources for Amazon Managed Prometheus
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "sentry_remote_write_assume" {
  count  = var.create_prometheus_server == true ? 1 : 0

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
  count              = var.create_prometheus_server == true ? 1 : 0
  name               = var.service_account_iam_role_name
  description        = var.service_account_iam_role_description
  assume_role_policy = data.aws_iam_policy_document.sentry_remote_write_assume[0].json
}

resource "aws_iam_policy" "sentry_amp_write" {
  count       = var.create_prometheus_server == true ? 1 : 0
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
  count      = var.create_prometheus_server == true ? 1 : 0
  role       = aws_iam_role.sentry_eks_amp_role[0].name
  policy_arn = aws_iam_policy.sentry_amp_write[0].arn
}
