variable "aws_region" {
  description = "Region for the state bucket. The backend block region must match."
  type        = string
  default     = "us-east-1"
}

variable "allowed_account_ids" {
  description = "Optional account guard."
  type        = list(string)
  default     = []
}

variable "name_prefix" {
  description = "Prefix for the state bucket and the optional lock table."
  type        = string
  default     = "tf004-dev"
}

variable "create_dynamodb_lock_table" {
  description = "Create a PAY_PER_REQUEST DynamoDB lock table. Terraform 1.10+ can lock with use_lockfile in S3 instead. The exam still covers DynamoDB locking, so the default is on. The table costs almost nothing while idle."
  type        = bool
  default     = true
}
