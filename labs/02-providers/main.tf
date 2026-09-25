provider "aws" {
  region              = var.aws_region
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null
}

provider "aws" {
  alias               = "secondary"
  region              = var.secondary_region
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null
}

data "aws_caller_identity" "current" {}

data "aws_region" "primary" {}

data "aws_region" "secondary" {
  provider = aws.secondary
}

data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

check "identity_present" {
  assert {
    condition     = data.aws_caller_identity.current.account_id != ""
    error_message = "Caller identity did not return an account id. Check AWS credentials."
  }
}
