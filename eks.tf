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

# module "eks" {
#   source = "../.."

#   cluster_name                    = local.name
#   cluster_version                 = local.cluster_version
#   cluster_service_ipv4_cidr       = "172.16.0.0/16"
#   cluster_endpoint_private_access = true
#   cluster_endpoint_public_access  = true

#   cluster_addons = {
#     coredns = {
#       resolve_conflicts = "OVERWRITE"
#     }
#     kube-proxy = {}
#     vpc-cni = {
#       resolve_conflicts = "OVERWRITE"
#     }
#   }

#   cluster_encryption_config = [{
#     provider_key_arn = aws_kms_key.eks.arn
#     resources        = ["secrets"]
#   }]

#   cluster_security_group_additional_rules = {
#     admin_access = {
#       description = "Admin ingress to Kubernetes API"
#       cidr_blocks = ["10.97.0.0/30"]
#       protocol    = "tcp"
#       from_port   = 443
#       to_port     = 443
#       type        = "ingress"
#     }
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   enable_irsa = true

#   eks_managed_node_group_defaults = {
#     ami_type       = "AL2_x86_64"
#     disk_size      = 50
#     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
#   }

#   eks_managed_node_groups = {
#     # Default node group - as provided by AWS EKS
#     default_node_group = {}

#     # Default node group - as provided by AWS EKS using Bottlerocket
#     bottlerocket_default = {
#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"
#     }

#     # Adds to the AWS provided user data
#     bottlerocket_add = {
#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"

#       # this will get added to what AWS provides
#       bootstrap_extra_args = <<-EOT
#       # extra args added
#       [settings.kernel]
#       lockdown = "integrity"
#       EOT
#     }

#     # Custom AMI, using module provided bootstrap data
#     bottlerocket_custom = {
#       # Current bottlerocket AMI
#       ami_id   = "ami-0ff61e0bcfc81dc94"
#       platform = "bottlerocket"

#       # use module user data template to boostrap
#       enable_bootstrap_user_data = true
#       # this will get added to the template
#       bootstrap_extra_args = <<-EOT
#       # extra args added
#       [settings.kernel]
#       lockdown = "integrity"

#       [settings.kubernetes.node-labels]
#       "label1" = "foo"
#       "label2" = "bar"

#       [settings.kubernetes.node-taints]
#       "dedicated" = "experimental:PreferNoSchedule"
#       "special" = "true:NoSchedule"
#       EOT
#     }

#     # Use existing/external launch template
#     external_lt = {
#       create_launch_template  = false
#       launch_template_name    = aws_launch_template.external.name
#       launch_template_version = aws_launch_template.external.default_version
#     }

#     # Use a custom AMI
#     custom_ami = {
#       # Current default AMI used by managed node groups - pseudo "custom"
#       ami_id = "ami-0caf35bc73450c396"

#       # This will ensure the boostrap user data is used to join the node
#       # By default, EKS managed node groups will not append bootstrap script;
#       # this adds it back in using the default template provided by the module
#       # Note: this assumes the AMI provided is an EKS optimized AMI derivative
#       enable_bootstrap_user_data = true
#     }

#     # Complete
#     complete = {
#       name            = "complete-eks-mng"
#       use_name_prefix = false

#       subnet_ids = module.vpc.private_subnets

#       min_size     = 1
#       max_size     = 7
#       desired_size = 1

#       ami_id                     = "ami-0caf35bc73450c396"
#       enable_bootstrap_user_data = true
#       bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

#       pre_bootstrap_user_data = <<-EOT
#         export CONTAINER_RUNTIME="containerd"
#         export USE_MAX_PODS=false
#       EOT

#       post_bootstrap_user_data = <<-EOT
#         echo "you are free little kubelet!"
#       EOT

#       capacity_type        = "SPOT"
#       disk_size            = 256
#       force_update_version = true
#       instance_types       = ["m6i.large", "m5.large", "m5n.large", "m5zn.large", "m3.large", "m4.large"]
#       labels = {
#         GithubRepo = "terraform-aws-eks"
#         GithubOrg  = "terraform-aws-modules"
#       }

#       taints = [
#         {
#           key    = "dedicated"
#           value  = "gpuGroup"
#           effect = "NO_SCHEDULE"
#         }
#       ]

#       remote_access = {
#         ec2_ssh_key = "my-ssh-key"
#       }

#       update_config = {
#         max_unavailable_percentage = 50 # or set `max_unavailable`
#       }

#       description = "EKS managed node group example launch template"

#       ebs_optimized           = true
#       vpc_security_group_ids  = [aws_security_group.additional.id]
#       disable_api_termination = false
#       enable_monitoring       = true

#       block_device_mappings = {
#         xvda = {
#           device_name = "/dev/xvda"
#           ebs = {
#             volume_size           = 75
#             volume_type           = "gp3"
#             iops                  = 3000
#             throughput            = 150
#             encrypted             = true
#             kms_key_id            = aws_kms_key.ebs.arn
#             delete_on_termination = true
#           }
#         }
#       }

#       metadata_options = {
#         http_endpoint               = "enabled"
#         http_tokens                 = "required"
#         http_put_response_hop_limit = 2
#       }

#       create_iam_role          = true
#       iam_role_name            = "eks-managed-node-group-complete-example"
#       iam_role_use_name_prefix = false
#       iam_role_description     = "EKS managed node group complete example role"
#       iam_role_tags = {
#         Purpose = "Protector of the kubelet"
#       }
#       iam_role_additional_policies = [
#         "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#       ]

#       create_security_group          = true
#       security_group_name            = "eks-managed-node-group-complete-example"
#       security_group_use_name_prefix = false
#       security_group_description     = "EKS managed node group complete example security group"
#       security_group_rules = {
#         phoneOut = {
#           description = "Hello CloudFlare"
#           protocol    = "udp"
#           from_port   = 53
#           to_port     = 53
#           type        = "egress"
#           cidr_blocks = ["1.1.1.1/32"]
#         }
#         phoneHome = {
#           description                   = "Hello cluster"
#           protocol                      = "udp"
#           from_port                     = 53
#           to_port                       = 53
#           type                          = "egress"
#           source_cluster_security_group = true # bit of reflection lookup
#         }
#       }
#       security_group_tags = {
#         Purpose = "Protector of the kubelet"
#       }

#       tags = {
#         ExtraTag = "EKS managed node group complete example"
#       }
#     }
#   }

#   tags = local.tags
# }

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_availability_zones" "available" {
}
