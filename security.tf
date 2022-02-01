# Sentry DB Security Group
resource "aws_security_group" "sentry_rds_pg" {
  name        = "${local.sentry_prefix}-rds-pg"
  description = "Database security group for the Sentry application."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sentry_rds_pg_allow_from_bastion" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.bastion_security_group_id
  security_group_id        = aws_security_group.sentry_rds_pg.id
}

resource "aws_security_group_rule" "sentry_rds_pg_allow_from_eks_cluster" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.cluster_security_group_id
  security_group_id        = aws_security_group.sentry_rds_pg.id
}

resource "aws_security_group_rule" "sentry_rds_pg_allow_from_eks_node" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = var.node_security_group_id
  security_group_id        = aws_security_group.sentry_rds_pg.id
}
