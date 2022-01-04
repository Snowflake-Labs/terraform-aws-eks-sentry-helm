# Required Variables
variable "vpc_name" {
  description = "The name of the VPC that will be created to house the EKS cluster."
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster to create for sentry."
  type        = string
}

variable "lb_cert" {
  description = "Load Balancer Cert"
  type        = string
}

variable "sentry_namespace" {
  description = "Kuberentes namespace to deploy Sentry application"
  type        = string
}

variable "sentry_version" {
  description = "Sentry application deployment version"
  type        = string
}

variable "redirect_uri" {
  description = "Okta Redirect URI"
  type        = string
}

variable "authorization_url" {
  description = "Okta Authorization URL"
  type        = string
}

variable "token_url" {
  description = "Okta Token URL"
  type        = string
}

variable "user_url" {
  description = "Okta user URL"
  type        = string
}

variable "private_subnet_ids" {

}

variable "private_subnet_cidr_blocks" {

}

variable "vpc_id" {

}


# Optional Variables
variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "env" {
  description = "Environment to be test/dev/prod."
  type        = string
  default     = "dev"
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use."
  type        = string
  default     = "1.21"
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "allowed_cidr_blocks" {
  description = "DEV VPN CIDR block"
  type        = string
  default     = []
}

variable "tines_access_sg" {
  description = "Tines Access Security group"
  type        = string
}

variable "client_id_arn" {
  type = string

  validation {
    condition = can(regex(
      "^arn:aws:secretsmanager:(us|ap)-(west|south)-\\d:\\d{12}:secret:(test|prod)/okta/client-id[a-zA-Z0-9/_+=.@-]+$",
      var.client_id_arn
    ))
    error_message = "The secrets arn doesn't match the regex ^arn:aws:secretsmanager:(us|ap)-(west|south)-\\d:\\d{12}:secret:(test|prod)/okta/client-id[a-zA-Z0-9/_+=.@-]+$."
  }
}

variable "client_secret_arn" {
  type = string

  validation {
    condition = can(regex(
      "^arn:aws:secretsmanager:(us|ap)-(west|south)-\\d:\\d{12}:secret:(test|prod)/okta/client-secret[a-zA-Z0-9/_+=.@-]+$",
      var.client_secret_arn
    ))
    error_message = "The secrets arn doesn't match the regex ^arn:aws:secretsmanager:(us|ap)-(west|south)-\\d:\\d{12}:secret:(test|prod)/okta/client-secret[a-zA-Z0-9/_+=.@-]+$."
  }
}


variable "client_id" {

}

variable "client_secret" {

}

variable "tines_access" {

}



locals {
  private_subnets            = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  private_subnet_cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnet_cidr_blocks
  vpc_id                     = data.terraform_remote_state.vpc.outputs.vpc_id
  db_password                = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string)["CASSANDRA_PASSWORD"]
  client_id                  = jsondecode(data.aws_secretsmanager_secret_version.client_id.secret_string)["CLIENT_ID"]
  client_secret              = jsondecode(data.aws_secretsmanager_secret_version.client_secret.secret_string)["CLIENT_SECRET"]
  tines_access               = data.terraform_remote_state.tines.outputs.tines_app_security_group_id
}


