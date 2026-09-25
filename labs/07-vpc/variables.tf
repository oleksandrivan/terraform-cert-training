variable "aws_region" {
  description = "Region for the VPC lab."
  type        = string
  default     = "us-east-1"
}

variable "allowed_account_ids" {
  description = "Optional account guard."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Off by default. A NAT gateway is about 0.045 USD per hour."
  type        = bool
  default     = false
}

variable "acknowledge_nat_cost" {
  description = "Must be true when enable_nat_gateway is true."
  type        = bool
  default     = false

  validation {
    condition     = var.acknowledge_nat_cost || !var.enable_nat_gateway
    error_message = "Set acknowledge_nat_cost = true before enabling a NAT gateway."
  }
}
