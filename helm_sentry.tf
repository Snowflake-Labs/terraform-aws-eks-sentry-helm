# resource "helm_release" "sentry" {
#   name       = "sentry"
#   chart      = "sentry"
#   repository = "https://sentry-kubernetes.github.io/charts"
#   version    = "12.0.0"

#   timeout = 600
#   wait    = false

#   values = [
#     templatefile(
#       "${path.module}/templates/sentry_values.yaml",
#       {
#         module_prefix = "${var.module_prefix}",

#         sentry_email    = "${var.sentry_email}",
#         sentry_password = "${var.sentry_password}",

#         sentry_dns_name         = "${local.sentry_dns_name}",
#         subdomain_cert_arn      = "${var.subdomain_cert_arn}",
#         allowed_cidr_blocks_str = "${join(",", var.allowed_cidr_blocks)}",
#         private_subnet_ids_str  = "${join(",", var.private_subnet_ids)}",
#         public_subnet_ids_str   = "${join(",", var.public_subnet_ids)}",
#         # postgres_db_host        = "${module.sentry_rds_pg.this_rds_cluster_endpoint}",
#         # postgres_db_name        = "${local.db_name}",
#         # postgres_username       = "${local.db_user}",
#         # postgres_password       = "${local.db_pass}",
#       }
#     )
#   ]

#   depends_on = [
#     helm_release.lb_controller,
#     helm_release.external_dns,
#   ]
# }


resource "helm_release" "sentry" {
  name  = "sentry"
  chart = "${path.module}/helm_sentry/"

  timeout           = 600
  wait              = false
  dependency_update = true

  values = [
    templatefile(
      "${path.module}/templates/sentry_values.yaml",
      {
        module_prefix   = "${var.module_prefix}",
        sentry_email    = "${var.sentry_email}",
        sentry_password = "${var.sentry_password}",

        sentry_dns_name         = "${local.sentry_dns_name}",
        subdomain_cert_arn      = "${var.subdomain_cert_arn}",
        allowed_cidr_blocks_str = "${join(",", var.allowed_cidr_blocks)}",
        private_subnet_ids_str  = "${join(",", var.private_subnet_ids)}",
        public_subnet_ids_str   = "${join(",", var.public_subnet_ids)}",
        tags                    = "environment=${var.env}"
        # postgres_db_host        = "${module.sentry_rds_pg.this_rds_cluster_endpoint}",
        # postgres_db_name        = "${local.db_name}",
        postgres_username = "${local.db_user}",
        postgres_password = "${local.db_pass}",
      }
    )
  ]

  depends_on = [
    helm_release.lb_controller,
    helm_release.external_dns,
  ]
}
