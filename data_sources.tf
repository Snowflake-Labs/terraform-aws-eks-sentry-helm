data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "sfc-security-${var.region}-terraform-backend"
    key    = "IR/vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "tines" {
  backend = "s3"
  config = {
    bucket = "sfc-security-${var.region}-terraform-backend"
    key    = "IR/tines/terraform.tfstate"
    region = var.region
  }
}

data "aws_secretsmanager_secret" "db_password" {
  arn = var.cassandra_password_arn
}

data "aws_secretsmanager_secret" "client_id" {
  arn = var.client_id_arn
}

data "aws_secretsmanager_secret" "client_secret" {
  arn = var.client_secret_arn
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

data "aws_secretsmanager_secret_version" "client_id" {
  secret_id = data.aws_secretsmanager_secret.client_id.id
}

data "aws_secretsmanager_secret_version" "client_secret" {
  secret_id = data.aws_secretsmanager_secret.client_secret.id
}

locals {
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  private_subnet_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  db_password                = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["CASSANDRA_PASSWORD"]
  client_id                  = jsondecode(data.aws_secretsmanager_secret_version.client_id.secret_string)["CLIENT_ID"]
  client_secret              = jsondecode(data.aws_secretsmanager_secret_version.client_secret.secret_string)["CLIENT_SECRET"]
  tines-access               = data.terraform_remote_state.tines.outputs.tines_app_security_group_id
}
