module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.2.1"

  cluster_name                         = var.eks_cluster_name
  cluster_version                      = var.kubernetes_version
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidr_blocks

  vpc_id      = var.vpc_id
  subnet_ids  = var.private_subnet_ids
  enable_irsa = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
  cloudwatch_log_group_retention_in_days = 0

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    node-group-1 = {
      min_size     = 3
      max_size     = 5
      desired_size = 3

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
      labels = {
        environment = "${var.env}"
        app         = "sentry"
      }

      update_config = {
        max_unavailable_percentage = 80 # or set `max_unavailable`
      }

      tags = {
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

    egress_cluster_all_ports = {
      description                   = "Internal communcation All port to cluster SG"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 0
      type                          = "egress"
      source_cluster_security_group = true
    }

    engress_node_group_all_traffic = {
      description = "Internal communcation to postgres"
      protocol    = "all"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress_cluster_all_ports = {
      description = "Internal communcation 1025-65535"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }

    ingress_cluster_443 = {
      description = "Internal communcation 1025-65535"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      self        = true
    }

  }

  cluster_timeouts = {
    create = "30m"
    delete = "30m"
  }
}

# resource "kubernetes_namespace" "sentry" {
#   metadata {
#     name = var.sentry_namespace
#   }
#   name = var.sentry_namespace

#   timeouts {
#     delete = "30m"
#   }

#   depends_on = [
#     module.eks
#   ]
# }

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}
