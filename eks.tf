module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "17.24.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.kubernetes_version

  vpc_id  = var.vpc_id
  subnets = var.private_subnet_ids

  enable_irsa                          = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidr_blocks

  cluster_enabled_log_types     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cluster_log_retention_in_days = 0

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    node-group-1 = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        environment = "${var.env}"
      }
    }
  }

  cluster_security_group_additional_rules = {
    admin_access = {
      description = "Admin ingress to Kubernetes API"
      cidr_blocks = var.allowed_cidr_blocks
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
    }
  }

  node_security_group_additional_rules = {
    ingress_cluster_9443 = {
      description                   = "Cluster API to node groups webhook"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_cluster_8443 = {
      description                   = "Cluster API to node groups webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_cluster_80 = {
      description = "Internal communcation 80"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      self        = true
    }

    engress_cluster_80 = {
      description = "Internal communcation 80"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "egress"
      self        = true
    }

    engress_cluster_5432 = {
      description              = "Internal communcation to postgres"
      protocol                 = "tcp"
      from_port                = 5432
      to_port                  = 5432
      type                     = "egress"
      source_security_group_id = module.security_group_database.security_group_id
    }
  }

  map_users    = var.map_users
  map_accounts = var.map_accounts

  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}
