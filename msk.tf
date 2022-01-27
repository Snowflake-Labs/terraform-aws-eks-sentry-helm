resource "random_id" "config_id" {
  byte_length = 2
}

module "sentry_kafka" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "0.8.3"

  name                      = "${local.sentry_prefix}-${try(random_id.config_id.hex, "")}"
  kafka_version             = var.kafka_version
  number_of_broker_nodes    = 4
  broker_instance_type      = var.broker_instance_type
  cloudwatch_logs_enabled   = true
  cloudwatch_logs_log_group = aws_cloudwatch_log_group.sentry_msk.name

  vpc_id                = var.vpc_id
  zone_id               = var.private_hosted_zone_id
  subnet_ids            = var.private_subnet_ids
  create_security_group = true
}
