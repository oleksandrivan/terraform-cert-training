variable "aws_region" {
  description = "Region for the default AWS provider."
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Region for the aliased provider. A second provider block is how Terraform configures multi-region or multi-account workflows."
  type        = string
  default     = "us-west-2"
}

variable "allowed_account_ids" {
  description = "Optional account guard. Empty allows whichever account your credentials resolve to."
  type        = list(string)
  default     = []
}
