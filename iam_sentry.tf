# 1. external-dns IAM Role Policy Document
data "aws_iam_policy_document" "external_dns_policy_doc" {
  statement {
    sid = "ChangeResourceRecordSets"
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    sid = "ListResourceRecordSets"
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

# 2. external-dns IAM Role Policy
resource "aws_iam_policy" "external_dns_policy" {
  name        = "sentry-external-dns"
  path        = "/"
  description = "Policy for external-dns service"
  policy = data.aws_iam_policy_document.external_dns_policy_doc.json
}

# 3. external-dns Assume Role Policy Document
data "aws_iam_policy_document" "external_dns_irsa_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_url}:sub"
      values = ["system:serviceaccount:kube-system:external-dns"]
    }
  }
}

# 4. external-dns IAM Role
resource "aws_iam_role" "external_dns_role" {
  name               = "sentry-external-dns" # "${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_irsa_assume_role_policy_doc.json
}

# 5. external-dns IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

# 6. external-dns IRSA into the kube-system namespace.
resource "kubernetes_service_account" "external_dns_service_account" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_role.arn
    }
  }
  automount_service_account_token = true
}

# 7. EKS Cluster Role
resource "kubernetes_cluster_role" "external_dns_cluster_role" {
  metadata {
    name = "external-dns"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["networking.istio.io"]
    resources  = ["gateways"]
    verbs      = ["get", "list", "watch"]
  }
}

# 8. EKS Cluster Role Binding
resource "kubernetes_cluster_role_binding" "external_dns_binding" {
  metadata {
    name = "external-dns"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_dns_cluster_role.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.external_dns_service_account.metadata.0.name
    namespace = kubernetes_service_account.external_dns_service_account.metadata.0.namespace
  }
}
