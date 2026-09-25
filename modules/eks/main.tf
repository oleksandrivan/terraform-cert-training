locals {
  # String "true"/"false" matches the VPC CNI add-on schema. A JSON boolean is rejected.
  vpc_cni_configuration = jsonencode({
    enableNetworkPolicy = var.enable_network_policy ? "true" : "false"
  })
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  # STANDARD refuses the extended-support price tier. Stay on a version
  # still in standard support (1.34, 1.35, or 1.36 as of September 2026).
  upgrade_policy = {
    support_type = "STANDARD"
  }

  enabled_log_types                        = var.enabled_log_types
  deletion_protection                      = false
  endpoint_public_access                   = true
  endpoint_private_access                  = true
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.node_subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  addons = {
    eks-pod-identity-agent = {
      before_compute              = true
      most_recent                 = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
    }
    vpc-cni = {
      before_compute              = true
      most_recent                 = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values        = local.vpc_cni_configuration
    }
    kube-proxy = {
      most_recent                 = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
    }
    coredns = {
      most_recent                 = true
      preserve                    = false
      resolve_conflicts_on_create = "OVERWRITE"
      configuration_values = jsonencode({
        replicaCount = 1
        resources = {
          limits = {
            cpu    = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
        }
      })
    }
  }

  eks_managed_node_groups = {
    system = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      disk_size      = var.disk_size

      # Karpenter's controller selects this label so it does not run on nodes it manages.
      labels = {
        "karpenter.sh/controller" = "true"
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }

      iam_role_attach_cni_policy = var.attach_cni_policy_to_node_role
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  node_security_group_tags = merge(var.tags, {
    "karpenter.sh/discovery" = var.name
  })

  tags = var.tags
}

module "vpc_cni_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_cni_pod_identity ? 1 : 0

  name                               = "${var.name}-vpc-cni"
  use_name_prefix                    = false
  attach_aws_vpc_cni_policy          = true
  aws_vpc_cni_enable_ipv4            = true
  aws_vpc_cni_enable_cloudwatch_logs = var.enable_network_policy

  associations = {
    aws_node = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "aws-node"
    }
  }

  tags = var.tags
}
