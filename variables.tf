# Required Variables
variable "kubernetes_version" {
  description = "The version of the EKS cluster to create for sentry."
  type        = string
}

variable "sentry_helm_chart_version" {
  description = "Sentry Helm Chart version."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created."
  type        = string
}

variable "sentry_root_user_email" {
  description = "The email used to login for the first time."
  type        = string
}

variable "sentry_root_user_password" {
  description = "The ARN for the password login password used to login for the first time."
  type        = string
}

variable "hosted_zone_subdomain" {
  description = "Hosted zone subdomain name on which sentry domain will be created."
  type        = string
}

variable "subdomain_cert_arn" {
  description = "ACM Cert ARN of the wildcart cert for the hosted zone domain name."
  type        = string
}

variable "db_host" {
  type = string
}

variable "db_port" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_user" {
  type = string
}

variable "db_pass" {
  type = string
}

variable "smtp_host" {
  type = string
}

variable "smtp_username" {
  type = string
}

variable "smtp_password" {
  type = string
}
variable "module_prefix" {
  type = string
}

variable "bastion_security_group_id" {
  description = "Security Group of the bastion host in the public subnet."
  type        = string
}

variable "sentry_slack_client_id" {
  type = string
}

variable "sentry_slack_client_secret" {
  type = string
}

variable "sentry_slack_signing_secret" {
  type = string
}

variable "sentry_secret_key" {
  type = string
}

# Optional Variables
variable "app_name" {
  description = "Name of the app."
  type        = string
  default     = "sentry"
}

variable "sentry_namespace" {
  description = "Kuberentes namespace to deploy Sentry application"
  type        = string
  default     = "sentry"
}

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
  description = "Private subnet IDs to add kubernetes cluster on."
  type        = list(string)
  default     = []
}

variable "public_subnet_ids" {
  description = "Publlic subnet IDs to add kubernetes cluster on."
  type        = list(string)
  default     = []
}

variable "external_dns_zone_type" {
  description = "External-dns Helm chart AWS DNS zone type (public, private or empty for both)"
  type        = string
  default     = ""
}

variable "az_count" {
  description = "Number of AZs to cover in a given region."
  type        = string
  default     = 1
}

variable "kafka_version" {
  type        = string
  description = "Version of the kafka service."
  default     = "2.4.1.1"
}

variable "broker_instance_type" {
  type        = string
  description = "Broker instance type."
  default     = "kafka.m5.large"
}

variable "number_of_broker_nodes" {
  type        = string
  description = "Number of broker instance nodes. NOTE: This has to be a multiple of the # of subnet_ids."
  default     = 2
}

variable "domain_name_suffix" {
  description = "Prefix for domain name."
  type        = string
  default     = null
}

locals {
  sentry_prefix = "${var.module_prefix}-${var.app_name}"
}

locals {
  sentry_dns_name = var.domain_name_suffix != null ? "${var.app_name}-${var.domain_name_suffix}.${var.hosted_zone_subdomain}" : "${var.app_name}.${var.hosted_zone_subdomain}"
}

#---------------------------------------------------------------------------------------------------------------------
# Configure Monitoring
# ---------------------------------------------------------------------------------------------------------------------

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

variable "create_prometheus_server" {
  description = "Should this module create a Prometheus server statefulset in the EKS cluster for Amazon Managed Prometheus?"
  type        = bool
  default     = true
}

variable "sentry_amp_workspace_id" {
  description = "SENTRY AMP workspace ID."
  type        = string
}

variable "sentry_amp_endpoint" {
  description = "SENTRY AMP ENDPOINT."
  type        = string
}

variable "sentry_amp_workspace_arn" {
  description = "SENTRY AMP workspace ARN."
  type        = string
}

variable "account_id" {
  description = "ID of Account."
}

variable "oidc_provider" {
  description = "OIDC provider of EKS Cluster."
}
