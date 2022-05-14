output "sentry_private_lb_sg_id" {
  description = "Private LB security group."
  value       = aws_security_group.sentry_private_ingress_sg.0.id

  depends_on = [aws_security_group.sentry_private_ingress_sg]
}
