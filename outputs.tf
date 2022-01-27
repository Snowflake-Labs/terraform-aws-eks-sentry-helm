output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console."
  value       = module.eks.cluster_primary_security_group_id
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "Cluster IAM Role."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.eks.cluster_iam_role_name
}

output "aws_auth_configmap_yaml" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks.aws_auth_configmap_yaml
}

output "eks_managed_node_groups" {
  description = "Outputs from node groups"
  value       = module.eks.eks_managed_node_groups
}

output "kafka_brokers" {
  description = "Kafka broker nodes hostnames and ports."
  value       = module.sentry_kafka.all_brokers
}

output "kafka_bootstrap_brokers" {
  description = "Kafka broker nodes hostnames and ports."
  value       = module.sentry_kafka.bootstrap_brokers
}
