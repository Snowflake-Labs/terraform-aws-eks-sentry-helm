# RDS Aurora PostGreSQL Version 11.9
module "sentry_db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 2.0"

  name           = "${var.module_prefix}-pg11-db"
  database_name  = local.db_name
  username       = local.db_user
  password       = local.db_pass
  engine         = "aurora-postgresql"
  engine_version = "11.9"

  vpc_id                  = var.vpc_id
  subnets                 = var.private_subnet_ids
  replica_count           = var.az_count
  vpc_security_group_ids  = [aws_security_group.sentry_rds.id]
  allowed_security_groups = var.bastion_security_group_id != null ? [var.bastion_security_group_id] : []

  instance_type         = "db.t3.medium"
  instance_type_replica = "db.t3.medium"
  storage_encrypted     = true
  apply_immediately     = true
  monitoring_interval   = 10

  db_parameter_group_name         = aws_db_parameter_group.aurora_db_postgres11_parameter_group.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora_cluster_postgres11_parameter_group.id
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_db_parameter_group" "aurora_db_postgres11_parameter_group" {
  name        = "aurora-${local.prefix}-db-postgres11-parameter-group"
  family      = "aurora-postgresql11"
  description = "aurora-db-postgres11-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres11_parameter_group" {
  name        = "aurora-${local.prefix}-postgres11-cluster-parameter-group"
  family      = "aurora-postgresql11"
  description = "aurora-postgres11-cluster-parameter-group"
}
