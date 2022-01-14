resource "kubernetes_namespace" "sentry" {
  metadata {
    name = var.sentry_namespace
  }
}

resource "helm_release" "sentry" {
  name         = "sentry"
  repository   = "https://sentry-kubernetes.github.io/charts"
  chart        = "sentry"
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
        allowed_cidr_blocks = "${var.allowed_cidr_blocks}",

        postgres_db_host = "${module.sentry_db.this_rds_cluster_endpoint}"
        postgres_db_name = "${local.db_name}",
        postgres_username = "${local.db_user}",
        postgres_password = "${local.db_pass}",
      }
    )
  ]
}

resource "helm_release" "external_dns" {
  chart      = "external-dns"
  namespace  = "kube-system"
  name       = "external-dns"
  version    = "6.1.1"
  repository = "https://charts.bitnami.com/bitnami"

  set {
    name  = "rbac.create"
    value = false
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.external_dns_service_account.metadata.0.name
  }

  set {
    name  = "rbac.pspEnabled"
    value = false
  }

  set {
    name  = "name"
    value = "sentry-external-dns" # "${var.cluster_name}-external-dns"
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set_string {
    name  = "policy"
    value = "sync"
  }

  set_string {
    name  = "logLevel"
    value = "warn" # var.external_dns_chart_log_level
  }

  set {
    name  = "sources"
    value = "{ingress,service}"
  }

  set_string {
    name  = "aws.zoneType"
    value = var.external_dns_zone_type
  }

  set_string {
    name  = "aws.region"
    value = var.aws_region
  }
}
