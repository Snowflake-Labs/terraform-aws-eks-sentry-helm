module "sentry" {
  source = "../../"

  account_id                = var.account_id
  env                       = var.env
  module_prefix             = var.module_prefix
  sentry_helm_chart_version = var.sentry_helm_chart_version
  sentry_secret_key         = var.sentry_secret_key

  vpc_id                     = var.vpc_id
  private_subnet_ids         = var.private_subnet_ids
  public_subnet_ids          = var.public_subnet_ids
  allowed_cidr_blocks        = var.allowed_cidr_blocks
  allowed_security_group_ids = var.allowed_security_group_ids

  db_host = var.db_host
  db_port = var.db_port
  db_name = var.db_name
  db_user = var.db_user
  db_pass = var.db_pass

  sentry_root_user_email    = var.sentry_root_user_email
  sentry_root_user_password = var.sentry_root_user_password

  hosted_zone_subdomain     = var.hosted_zone_subdomain
  subdomain_cert_arn        = var.subdomain_cert_arn
}
