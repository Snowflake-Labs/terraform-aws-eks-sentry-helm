resource "aws_security_group" "sentry_sg" {
  name        = "sentry-sg"
  description = "controls access to kubernetes cluster."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sentry_sg_allow_from_vpn" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = aws_security_group.sentry_sg.id
}

resource "aws_security_group_rule" "sentry_sg_allow_to_vpn" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sentry_sg.id
}
