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

  smtp_enable   = var.smtp_enable
  smtp_host     = var.smtp_host
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password

  slack_enable                = var.slack_enable
  sentry_slack_client_id      = var.sentry_slack_client_id
  sentry_slack_client_secret  = var.sentry_slack_client_secret
  sentry_slack_signing_secret = var.sentry_slack_signing_secret

  create_prometheus_server    = var.create_prometheus_server
  oidc_provider               = var.oidc_provider
  sentry_amp_workspace_id     = var.sentry_amp_workspace_id
}
