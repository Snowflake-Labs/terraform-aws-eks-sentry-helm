data "aws_secretsmanager_secret" "db_secrets" {
  arn = var.db_secrets_arn
}

data "aws_secretsmanager_secret_version" "db_secrets" {
  secret_id = data.aws_secretsmanager_secret.db_secrets.id
}

locals {
  db_name = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["DATABASE_NAME"]
  db_user = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["DATABASE_USERNAME"]
  db_pass = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["DATABASE_PASSWORD"]
}
