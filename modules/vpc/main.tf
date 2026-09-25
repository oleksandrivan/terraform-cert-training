data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  # /20 private subnets (4096 addresses) and /24 public subnets.
  private_subnets = [for index, az in local.azs : cidrsubnet(var.cidr, 4, index)]
  public_subnets  = [for index, az in local.azs : cidrsubnet(var.cidr, 8, index + 48)]

  discovery_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = var.name
  cidr = var.cidr
  azs  = local.azs

  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  public_subnet_tags = merge(local.discovery_tags, {
    "kubernetes.io/role/elb" = 1
  })

  private_subnet_tags = merge(local.discovery_tags, {
    "kubernetes.io/role/internal-elb" = 1
  })

  tags = var.tags
}

# Gateway endpoints are free and keep S3 traffic off a NAT gateway.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(module.vpc.private_route_table_ids, module.vpc.public_route_table_ids)

  tags = merge(var.tags, {
    Name = "${var.name}-s3"
  })
}

data "aws_region" "current" {}

check "two_azs_for_eks" {
  assert {
    condition     = length(local.azs) >= 2
    error_message = "EKS needs subnets in at least two Availability Zones. az_count resolved to ${length(local.azs)}."
  }
}
