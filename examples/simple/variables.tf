# REQUIRED VARIABLES
variable "account_id" {
  description = "AWS account id."
  type        = string
}

variable "module_prefix" {
  description = "Prefix name to the resources."
  type        = string
}

variable "sentry_helm_chart_version" {
  description = "Sentry Helm Chart version."
  type        = string
  default     = "17.0.0"
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created."
  type        = string
}

variable "sentry_root_user_email" {
  description = "The email used to login for the first time."
  type        = string
}

variable "sentry_root_user_password" {
  description = "The password used to login for the first time."
  type        = string
}

variable "hosted_zone_subdomain" {
  description = "Hosted zone subdomain name on which Sentry hostname will be created."
  type        = string
}

variable "subdomain_cert_arn" {
  description = "ACM SSL Cert ARN for the Sentry host name."
  type        = string
}

variable "db_host" {
  description = "RDS database cluster endpoint."
  type        = string
}

variable "db_port" {
  description = "RDS database port."
  type        = string
}

variable "db_name" {
  description = "RDS database name."
  type        = string
}

variable "db_user" {
  description = "RDS database username."
  type        = string
}

variable "db_pass" {
  description = "RDS database password."
  type        = string
}

variable "sentry_secret_key" {
  description = "Sentry secret key."
  type = string
}



# OPTIONAL VARIABLES
variable "env" {
  description = "Environment to be test/dev/prod."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Name of the app."
  type        = string
  default     = "sentry"
}

variable "domain_name_suffix" {
  description = "Suffix for Sentry domain hostname."
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "Allowed CIDR blocks that can initiate connections to Sentry."
  type        = list(string)
  default     = []
}

variable "allowed_security_group_ids" {
  description = "Allowed SG IDs that can initiate connections to Sentry."
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to allow to connect to Sentry private loadbalancer."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Publlic subnet IDs to allow to connect to Sentry public loadbalancer."
  type        = list(string)
  default     = []
}
