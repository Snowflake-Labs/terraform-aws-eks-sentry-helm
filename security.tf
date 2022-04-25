resource "aws_security_group" "sentry_private_ingress_sg" {
  name        = "${var.app_name}-ingress-internal"
  description = "Private ingress SG to apply to the Sentry app."
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "sentry_private_ingress_allow_from_allowed_sg_ids" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.allowed_security_group_ids[count.index]

  security_group_id = aws_security_group.sentry_private_ingress_sg.id
}

resource "aws_security_group_rule" "sentry_private_ingress_allow_to_sentry_container" {
  type        = "egress"
  to_port     = 0
  from_port   = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.sentry_private_ingress_sg.id
}
