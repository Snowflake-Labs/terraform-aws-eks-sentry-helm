# Required Variables
variable "eks_cluster_name" {
  description = "The name of the EKS cluster to create for sentry."
  type        = string
}

variable "kubernetes_version" {
  description = "The version of the EKS cluster to create for sentry."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be created."
  type        = string
}

variable "sentry_email" {
  description = "The email used for logging in."
  type        = string
}

variable "sentry_password" {
  description = "The login password."
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

variable "db_secrets_arn" {
  type = string

  validation {
    condition = can(regex(
      "^arn:aws:secretsmanager:us-west-2:\\d{12}:secret:(dev|prod)/sentry/db-secrets-[a-zA-Z0-9/_+=.@-]+$",
      var.db_secrets_arn
    ))
    error_message = "The secrets arn doesn't match the regex ^arn:aws:secretsmanager:us-west-2:\\d{12}:secret:(dev|prod)/sentry/db-secrets-[a-zA-Z0-9/_+=.@-]+$."
  }
}

variable "bastion_security_group_id" {
  description = "Security Group of the bastion host in the public subnet."
  type        = string
}


# Optional Variables
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

variable "private_subnet_ids" {
  description = "Private subnet IDs to add kubernetes cluster on."
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

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "module_prefix" {
  description = "?"
  type        = string
  default     = ""
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

variable "arn_format" {
  type        = string
  default     = "aws"
  description = "ARNs identifier, usefull for GovCloud begin with `aws-us-gov-<region>`."
}

locals {
  sentry_dns_name = "sentry.${var.hosted_zone_subdomain}"
}
