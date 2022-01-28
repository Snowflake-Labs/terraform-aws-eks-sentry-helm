resource "aws_cloudwatch_log_group" "sentry_msk" {
  name = "/aws/msk/sentry"
}
