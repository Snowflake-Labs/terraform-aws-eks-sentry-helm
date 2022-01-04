resource "aws_security_group" "sentry_lb" {
  name        = "sentry-lb-sg"
  description = "controls access to internal loadbalancer from tines app."
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "sentry_lb_allow_from_tines_app" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = element([local.private_subnet_cidr_blocks], length([local.private_subnets]))
  security_group_id = aws_security_group.sentry_lb.id
}

# resource "aws_security_group_rule" "sentry_lb_allow_geff_lambda" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   security_group_id = var.geff-lambda-access
# }

# resource "aws_security_group_rule" "hive_lb_egress_allow_to_all" {
#   type              = "egress"
#   to_port           = 0
#   from_port         = 0
#   protocol          = "-1"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.hive-lb.id
# }
