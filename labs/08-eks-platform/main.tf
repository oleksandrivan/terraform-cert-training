data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ecrpublic_authorization_token" "token" {
  count    = local.need_ecr_public ? 1 : 0
  provider = aws.ecr_public
}

module "naming" {
  source = "../../modules/naming"

  prefix      = var.name_prefix
  environment = var.environment
  extra_tags = {
    Lab = "08-eks-platform"
  }
}

module "vpc" {
  source = "../../modules/vpc"
  count  = var.enable_vpc ? 1 : 0

  name               = module.naming.name_prefix
  cidr               = var.vpc_cidr
  az_count           = var.az_count
  cluster_name       = local.cluster_name
  enable_nat_gateway = var.enable_nat_gateway
  tags               = module.naming.tags
}

module "eks" {
  source = "../../modules/eks"
  count  = var.enable_eks ? 1 : 0

  name                     = local.cluster_name
  kubernetes_version       = var.kubernetes_version
  vpc_id                   = module.vpc[0].vpc_id
  control_plane_subnet_ids = module.vpc[0].private_subnet_ids
  node_subnet_ids          = local.node_subnet_ids
  enable_network_policy    = var.enable_network_policy
  enabled_log_types = var.enable_observability ? [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ] : []
  instance_types = var.node_instance_types
  desired_size   = var.node_desired_size
  min_size       = var.node_min_size
  max_size       = var.node_max_size
  tags           = module.naming.tags
}

module "ingress" {
  source = "../../modules/ingress"
  count  = var.enable_alb_controller || var.enable_vpc_lattice ? 1 : 0

  name                      = module.naming.name_prefix
  region                    = var.aws_region
  cluster_name              = module.eks[0].cluster_name
  vpc_id                    = module.vpc[0].vpc_id
  node_security_group_id    = module.eks[0].node_security_group_id
  enable_alb_controller     = var.enable_alb_controller
  enable_vpc_lattice        = var.enable_vpc_lattice
  enable_gateway_controller = var.enable_gateway_controller
  create_gateway_class      = var.create_gateway_class
  ecr_public_username       = local.ecr_public_username
  ecr_public_password       = local.ecr_public_password
  tags                      = module.naming.tags
}

module "storage" {
  source = "../../modules/storage"
  count  = local.enable_storage ? 1 : 0

  name                   = module.naming.name_prefix
  account_id             = data.aws_caller_identity.current.account_id
  cluster_name           = local.cluster_name_or_empty
  kubernetes_version     = var.kubernetes_version
  vpc_id                 = local.vpc_id
  subnet_ids             = local.node_subnet_ids
  node_security_group_id = local.node_security_group_id
  enable_s3              = var.enable_s3
  enable_ebs_csi         = var.enable_ebs_csi
  enable_efs             = var.enable_efs
  enable_s3_csi          = var.enable_s3_csi
  tags                   = module.naming.tags
}

module "karpenter" {
  source = "../../modules/karpenter"
  count  = var.enable_karpenter ? 1 : 0

  name                = module.eks[0].cluster_name
  cluster_endpoint    = module.eks[0].cluster_endpoint
  manage_manifests    = var.manage_karpenter_manifests
  ecr_public_username = local.ecr_public_username
  ecr_public_password = local.ecr_public_password
  tags                = module.naming.tags
}

module "security" {
  source = "../../modules/security"
  count  = var.enable_pod_identity_demo || var.enable_network_policy ? 1 : 0

  name                     = module.naming.name_prefix
  cluster_name             = module.eks[0].cluster_name
  bucket_arn               = local.bucket_arn
  enable_pod_identity_demo = var.enable_pod_identity_demo
  enable_network_policy    = var.enable_network_policy
  tags                     = module.naming.tags
}

module "observability" {
  source = "../../modules/observability"
  count  = var.enable_observability ? 1 : 0

  name               = module.naming.name_prefix
  cluster_name       = module.eks[0].cluster_name
  kubernetes_version = var.kubernetes_version
  tags               = module.naming.tags
}

module "capabilities" {
  source = "../../modules/capabilities"
  count  = var.enable_capabilities ? 1 : 0

  name         = module.naming.name_prefix
  cluster_name = module.eks[0].cluster_name
  bucket_arn   = local.bucket_arn
  tags         = module.naming.tags
}
