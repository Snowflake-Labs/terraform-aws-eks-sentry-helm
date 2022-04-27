data "kubernetes_service" "sentry_web" {
  metadata {
    name = "${var.module_prefix}-web"
  }

  depends_on = [helm_release.sentry]
}

data "kubernetes_service" "sentry_relay" {
  metadata {
    name = "${var.module_prefix}-relay"
  }
  depends_on = [helm_release.sentry]
}

resource "kubernetes_ingress" "sentry_ingress" {
  metadata {
    name      = local.sentry_prefix
    namespace = "default"

    labels = {
      app         = local.sentry_prefix
      environment = var.env
    }

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/tags"            = "environment=${var.env}"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/inbound-cidrs"   = "${join(",", var.allowed_cidr_blocks)}"
      "alb.ingress.kubernetes.io/subnets"         = "${join(",", var.public_subnet_ids)}"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = var.subdomain_cert_arn
      "external-dns.alpha.kubernetes.io/hostname" = local.sentry_dns_name
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/api/0/*"
          backend {
            service_name = data.kubernetes_service.sentry_web.metadata.0.name
            service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
          }
        }

        path {
          path = "/api/*"
          backend {
            service_name = data.kubernetes_service.sentry_relay.metadata.0.name
            service_port = data.kubernetes_service.sentry_relay.spec.0.port.0.port
          }
        }

        path {
          path = "/*"
          backend {
            service_name = data.kubernetes_service.sentry_web.metadata.0.name
            service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress" "sentry_ingress_private" {
  metadata {
    name      = "${local.sentry_prefix}-private"
    namespace = "default"

    labels = {
      app         = "${local.sentry_prefix}-private"
      environment = var.env
    }

    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internal"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
      "alb.ingress.kubernetes.io/tags"            = "environment=${var.env}"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/security-groups" = "${aws_security_group.sentry_private_ingress_sg.0.id}"
      "alb.ingress.kubernetes.io/subnets"         = "${join(",", var.private_subnet_ids)}"
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/certificate-arn" = var.subdomain_cert_arn
      "external-dns.alpha.kubernetes.io/hostname" = local.sentry_dns_name
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/api/0/*"
          backend {
            service_name = data.kubernetes_service.sentry_web.metadata.0.name
            service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
          }
        }

        path {
          path = "/api/*"
          backend {
            service_name = data.kubernetes_service.sentry_relay.metadata.0.name
            service_port = data.kubernetes_service.sentry_relay.spec.0.port.0.port
          }
        }

        path {
          path = "/*"
          backend {
            service_name = data.kubernetes_service.sentry_web.metadata.0.name
            service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
          }
        }
      }
    }
  }
}
