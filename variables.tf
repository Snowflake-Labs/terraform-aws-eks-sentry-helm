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

# SMTP Email Integration - The `smtp_enable` variable needs to be set to `true`.
variable "smtp_enable" {
  description = "Enable SMTP integration."
  type        = bool
  default     = false
}

variable "smtp_host" {
  description = "SMTP hostname"
  type        = string
  default     = null
}

variable "smtp_username" {
  description = "SMTP username."
  type        = string
  default     = null
}

variable "smtp_password" {
  description = "SMTP password."
  type        = string
  default     = null
}


## Slack Integration - The `slack_enable` variable needs to be set to `true`.
variable "slack_enable" {
  description = "Enable Sentry integration with Slack."
  type        = bool
  default     = false
}

variable "dependency_update" {
  description = "Dependency update flag flag."
  type        = bool
  default     = false
}

variable "wait" {
  description = "wait flag."
  type        = bool
  default     = false
}

variable "sentry_slack_client_id" {
  description = "Slack client id."
  type        = string
  default     = null
}

variable "sentry_slack_client_secret" {
  description = "Slack client secret."
  type        = string
  default     = null
}

variable "sentry_slack_signing_secret" {
  description = "Slack signing secret."
  type        = string
  default     = null
}

variable "enable_lb_access_logs" {
  description = "Create an S3 bucket and send ALB access logs to that bucket."
  type        = bool
  default     = false
}

# Prometheus Integration - The `create_prometheus_server` variable needs to be set to `true`.
variable "create_prometheus_server" {
  description = "Create a Prometheus server statefulset in the EKS cluster for Amazon Managed Prometheus."
  type        = bool
  default     = false
}

variable "grafana_namespace" {
  description = "Name of Grafana namespace."
  type        = string
  default     = "grafana"
}

variable "prometheus_namespace" {
  description = "Name of Prometheus namespace."
  type        = string
  default     = "prometheus"
}

variable "oidc_provider" {
  description = "OIDC provider of EKS Cluster."
  type        = string
  default     = null 
}

variable "sentry_amp_workspace_id" {
  description = "SENTRY AMP workspace ID."
  type        = string
  default     = null
}

variable "service_account_name" {
  description = "Name of IAM Proxy Service Account."
  type        = string
  default     = "sentry-iamproxy-service-account"
}

variable "service_account_iam_role_name" {
  description = "Name of IAM role for the service account"
  type        = string
  default     = "SENTRY-EKS-AMP-ServiceAccount-Role"
}

variable "service_account_iam_role_description" {
  description = "Description of IAM role for the service account"
  type        = string
  default     = "Sentry IAM role to be used by a K8s service account with write access to AMP"
}

variable "service_account_iam_policy_name" {
  description = "Name of the service account IAM policy"
  type        = string
  default     = "SENTRYAWSManagedPrometheusWriteAccessPolicy"
}


locals {
  sentry_prefix = "${var.module_prefix}-${var.app_name}"
}

locals {
  sentry_dns_name = var.domain_name_suffix != null ? "${var.app_name}-${var.domain_name_suffix}.${var.hosted_zone_subdomain}" : "${var.app_name}.${var.hosted_zone_subdomain}"
}
