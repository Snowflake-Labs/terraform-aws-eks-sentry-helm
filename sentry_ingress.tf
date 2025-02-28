data "kubernetes_service" "sentry_web" {
  metadata {
    name      = "sentry-web"
    namespace = var.sentry_kubernetes_namespace
  }

  depends_on = [
    helm_release.sentry,
    kubernetes_namespace.sentry
  ]
}

data "kubernetes_service" "sentry_relay" {
  metadata {
    name      = "sentry-relay"
    namespace = var.sentry_kubernetes_namespace
  }
  depends_on = [
    helm_release.sentry,
    kubernetes_namespace.sentry
  ]
}

locals {
  logs_annotation = var.logs_bucket_name != null ? "access_logs.s3.enabled=true,access_logs.s3.bucket=${var.logs_bucket_name},access_logs.s3.prefix=${var.module_prefix}" : ""
}


# The load balancers regex must match: 
# https://github.com/getsentry/self-hosted/blob/master/nginx/nginx.conf#L66C2-L78

resource "kubernetes_ingress_v1" "sentry_ingress" {
  metadata {
    name      = "sentry-ingress"
    namespace = var.sentry_kubernetes_namespace
    labels = {
      app         = "sentry-ingress"
      environment = var.env
    }

    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/tags"                     = "environment=${var.env}"
      "alb.ingress.kubernetes.io/listen-ports"             = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/inbound-cidrs"            = "${join(",", var.allowed_cidr_blocks)}"
      "alb.ingress.kubernetes.io/subnets"                  = "${join(",", var.public_subnet_ids)}"
      "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
      "alb.ingress.kubernetes.io/certificate-arn"          = var.subdomain_cert_arn
      "external-dns.alpha.kubernetes.io/hostname"          = local.sentry_dns_name
      "alb.ingress.kubernetes.io/load-balancer-attributes" = local.logs_annotation
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/api/0/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_web.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_web.spec.0.port.0.port
              }
            }
          }
        }

        path {
          path = "/api/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_relay.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_relay.spec.0.port.0.port
              }
            }
          }
        }

        path {
          path = "/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_web.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_web.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "sentry_ingress_private" {
  metadata {
    name      = "sentry-ingress-private"
    namespace = var.sentry_kubernetes_namespace

    labels = {
      app         = "sentry-ingress-private"
      environment = var.env
    }

    annotations = {
      "kubernetes.io/ingress.class"                        = "alb"
      "alb.ingress.kubernetes.io/scheme"                   = "internal"
      "alb.ingress.kubernetes.io/target-type"              = "ip"
      "alb.ingress.kubernetes.io/tags"                     = "environment=${var.env}"
      "alb.ingress.kubernetes.io/listen-ports"             = jsonencode([{ HTTPS = 443 }])
      "alb.ingress.kubernetes.io/security-groups"          = "${join(",", local.sentry_private_ingress_sg_ids)}"
      "alb.ingress.kubernetes.io/subnets"                  = "${join(",", var.private_subnet_ids)}"
      "alb.ingress.kubernetes.io/ssl-redirect"             = "443"
      "alb.ingress.kubernetes.io/certificate-arn"          = var.subdomain_cert_arn
      "external-dns.alpha.kubernetes.io/hostname"          = local.sentry_dns_name
      "alb.ingress.kubernetes.io/load-balancer-attributes" = local.logs_annotation
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/api/0/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_web.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_web.spec.0.port.0.port
              }
            }
          }
        }

        path {
          path = "/api/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_relay.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_relay.spec.0.port.0.port
              }
            }
          }
        }

        path {
          path = "/*"
          backend {
            service {
              name = data.kubernetes_service.sentry_web.metadata.0.name
              port {
                number = data.kubernetes_service.sentry_web.spec.0.port.0.port
              }
            }
          }
        }
      }
    }
  }
}
