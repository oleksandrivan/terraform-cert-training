variable "prefix" {
  description = "Passed into both module calls. The calls do not share variable values with each other."
  type        = string
  default     = "tf004"
}

module "dev" {
  source = "../../modules/naming"

  prefix      = var.prefix
  environment = "dev"
}

module "prod" {
  source = "../../modules/naming"

  prefix      = var.prefix
  environment = "prod"
  extra_tags = {
    CostCenter = "training"
  }
}

resource "terraform_data" "names" {
  input = {
    dev  = module.dev.name_prefix
    prod = module.prod.name_prefix
  }
}

# Registry modules add a version argument. This lab stays local so apply
# does not download or create cloud resources. The platform lab pins
# terraform-aws-modules/eks/aws ~> 21.0 and vpc/aws ~> 6.0.
#
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 6.0"
# }
