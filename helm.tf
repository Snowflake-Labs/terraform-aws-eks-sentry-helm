resource "kubernetes_namespace" "sentry" {
  metadata {
    name = var.sentry_namespace
  }
}

resource "helm_release" "sentry" {
  name         = var.sentry_namespace
  chart        = "${path.module}/helm/"
  namespace    = var.sentry_namespace
  force_update = true
  timeout      = 400

  values = [
    templatefile("${path.module}/helm/values.yaml",
      {
        # tines-allow         = "${var.tines-access}",
        lb-cert             = "${var.lb-cert}",
        db_password         = local.db_password,
        allowed_cidr_blocks = "${var.allowed_cidr_blocks}",
        client_id           = local.client_id,
        client_secret       = local.client_secret,
        redirect_uri        = "${var.redirect_uri}",
        authorization_url   = "${var.authorization_url}",
        token_url           = "${var.token_url}",
        user_url            = "${var.user_url}"
      }
    )
  ]

  depends_on = [kubernetes_namespace.sentry]
}

resource "kubernetes_service" "sentry_internal" {
  metadata {
    name      = "sentry-internal"
    namespace = kubernetes_namespace.sentry.metadata[0].name

    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-internal"               = "true",
      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" = "ELBSecurityPolicy-TLS-1-2-2017-01",
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"               = "${var.lb-cert}",
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"       = "http",
      "service.beta.kubernetes.io/aws-load-balancer-backend-port"           = "9000",
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"              = "443,8443"
      "service.beta.kubernetes.io/aws-load-balancer-security-groups"        = "${aws_security_group.hive-lb.id}"
    }

    labels = {
      "app.kubernetes.io/instance"   = "${kubernetes_namespace.hive.metadata.0.name}",
      "app.kubernetes.io/managed-by" = "Helm",
      "app.kubernetes.io/name"       = "sentry",
      "app.kubernetes.io/version"    = "${var.sentry_version}",
      "helm.sh/chart"                = "thehive-0.3.0"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/instance" = "${kubernetes_namespace.hive.metadata[0].name}",
      "app.kubernetes.io/name"     = "sentry"
    }

    port {
      port        = 443
      target_port = 9000
    }

    type = "LoadBalancer"
  }

  depends_on = [
    helm_release.sentry,
  ]
}
