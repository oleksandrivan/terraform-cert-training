provider "aws" {
  region              = var.aws_region
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = module.naming.tags
  }
}

module "naming" {
  source = "../../modules/naming"

  prefix      = "tf004"
  environment = "dev"
  extra_tags = {
    Lab = "07-vpc"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "${module.naming.name_prefix}-net"
  cidr               = "10.1.0.0/16"
  az_count           = 2
  cluster_name       = "${module.naming.name_prefix}-net"
  enable_nat_gateway = var.enable_nat_gateway
  tags               = module.naming.tags
}
