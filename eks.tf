module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                         = var.eks_cluster_name
  cluster_version                      = var.kubernetes_version
  vpc_id                               = var.vpc_id
  subnets                              = var.private_subnets_ids
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_enabled_log_types            = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days        = 0

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    node-group-1 = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        Environment = "${var.env}"
      }
    }
  }

  #map_roles    = var.map_roles
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
