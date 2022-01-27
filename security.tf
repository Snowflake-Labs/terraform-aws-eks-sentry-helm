# resource "aws_security_group" "sentry_sg" {
#   name        = "sentry-sg"
#   description = "controls access to kubernetes cluster."
#   vpc_id      = var.vpc_id
# }

# resource "aws_security_group_rule" "sentry_sg_allow_from_vpn" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = var.allowed_cidr_blocks
#   security_group_id = aws_security_group.sentry_sg.id
# }

# resource "aws_security_group_rule" "sentry_sg_allow_to_vpn" {
#   type              = "egress"
#   to_port           = 0
#   from_port         = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.sentry_sg.id
# }

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
  source_security_group_id = module.eks.cluster_security_group_id
  security_group_id        = aws_security_group.sentry_rds_pg.id
}

resource "aws_security_group_rule" "sentry_rds_pg_allow_from_eks_node" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = aws_security_group.sentry_rds_pg.id
}

# Sentry Kafka allow traffic from EKS nodes
resource "aws_security_group_rule" "sentry_kafka_allow_from_eks_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.eks.node_security_group_id
  security_group_id        = module.sentry_kafka.security_group_id
}
