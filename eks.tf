# module "eks" {
#   source = "terraform-aws-modules/eks/aws"

#   cluster_name                                = var.eks_cluster_name
#   cluster_version                             = var.kubernetes_version
#   vpc_id                                      = module.gha_vpc.vpc_id
#   subnets                                     = module.gha_vpc.private_subnet_ids
#   cluster_endpoint_private_access             = var.cluster_endpoint_private_access
#   cluster_endpoint_public_access_cidrs        = var.cluster_endpoint_public_access_cidrs
#   kubeconfig_file_permission                  = var.kubeconfig_file_permission
#   kubeconfig_output_path                      = var.kubeconfig_output_path
#   write_kubeconfig                            = var.write_kubeconfig
#   kubeconfig_aws_authenticator_command        = var.kubeconfig_aws_authenticator_command
#   kubeconfig_name                             = var.kubeconfig_name
#   kubeconfig_aws_authenticator_command_args   = var.kubeconfig_aws_authenticator_command_args
#   kubeconfig_aws_authenticator_env_variables  = var.kubeconfig_aws_authenticator_env_variables
#   cluster_enabled_log_types                   = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
#   cluster_log_retention_in_days               = 0



#   node_groups_defaults = {
#     ami_type  = "AL2_x86_64"
#     disk_size = 50
#   }

#   node_groups = {
#     node-group-1 = {
#       desired_capacity = 6
#       max_capacity     = 6
#       min_capacity     = 6

#       instance_types = ["t3.xlarge"]
#       capacity_type  = "ON_DEMAND"
#       k8s_labels = {
#         Environment = "${var.env}"
#       }
#     }
#   }

#   map_users    = var.map_users
#   map_accounts = var.map_accounts
# }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.kubernetes_version

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 0

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      additional_userdata  = ""
      asg_desired_capacity = 2
      #   additional_security_group_ids = [aws_security_group.sentry_sg.id]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      additional_userdata  = ""
      asg_desired_capacity = 1
      #   additional_security_group_ids = [aws_security_group.sentry_sg.id]
    },
  ]

  map_users    = var.map_users
  map_accounts = var.map_accounts
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}
