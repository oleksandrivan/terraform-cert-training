# Domain 5 practice module. No cloud resources — only naming and tags —
# so Phase 4 can apply it with zero AWS cost.

locals {
  name_prefix = "${var.prefix}-${var.environment}"

  tags = merge(
    {
      Environment = var.environment
      Project     = "terraform-cert-training"
      Exam        = "terraform-associate-004"
      ManagedBy   = "terraform"
    },
    var.extra_tags,
  )
}
