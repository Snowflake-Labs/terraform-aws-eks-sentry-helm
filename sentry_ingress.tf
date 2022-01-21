data "kubernetes_service" "sentry_web" {
  metadata {
    name = "sentry-web"
  }

  depends_on = [helm_release.sentry]
}

data "kubernetes_service" "sentry_relay" {
  metadata {
    name = "sentry-relay"
  }
  depends_on = [helm_release.sentry]
}

# resource "kubernetes_ingress" "sentry_ingress" {
#   metadata {
#     name      = "sentry-ingress"
#     namespace = "default"

#     labels = {
#       app         = "sentry"
#       environment = var.env
#     }

#     annotations = {
#       "kubernetes.io/ingress.class"               = "alb"
#       "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type"     = "ip"
#       "alb.ingress.kubernetes.io/tags"            = "Environment=${var.env}"
#       "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ HTTP = 80 }]) #, HTTPS = 443
#       "alb.ingress.kubernetes.io/inbound-cidrs"   = "${join(",", var.allowed_cidr_blocks)}"
#       "alb.ingress.kubernetes.io/subnets"         = "${join(",", var.public_subnet_ids)}"
#       "external-dns.alpha.kubernetes.io/hostname" = local.sentry_dns_name
#       # "alb.ingress.kubernetes.io/actions.ssl-redirect" = ""
#       # "alb.ingress.kubernetes.io/certificate-arn" = var.subdomain_cert_arn
#     }
#   }

#   spec {
#     rule {
#       http {
#         path {
#           path = "/api/0/*"
#           backend {
#             service_name = data.kubernetes_service.sentry_web.metadata.0.name
#             service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
#           }
#         }

#         path {
#           path = "/api/*"
#           backend {
#             service_name = data.kubernetes_service.sentry_relay.metadata.0.name
#             service_port = data.kubernetes_service.sentry_relay.spec.0.port.0.port
#           }
#         }

#         path {
#           path = "/*"
#           backend {
#             service_name = data.kubernetes_service.sentry_web.metadata.0.name
#             service_port = data.kubernetes_service.sentry_web.spec.0.port.0.port
#           }
#         }
#       }
#     }
#   }
# }
