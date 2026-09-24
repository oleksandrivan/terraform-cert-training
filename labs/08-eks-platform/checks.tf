check "dev_node_budget" {
  assert {
    condition     = var.node_desired_size <= 2
    error_message = "desired size is ${var.node_desired_size}. This lab expects 1 or 2 managed nodes. Checks warn and do not block apply."
  }
}

check "account_visible" {
  assert {
    condition     = data.aws_caller_identity.current.account_id != ""
    error_message = "aws_caller_identity returned an empty account id."
  }
}

check "region_matches_provider" {
  assert {
    condition     = data.aws_region.current.region == var.aws_region
    error_message = "The provider region does not match var.aws_region."
  }
}
