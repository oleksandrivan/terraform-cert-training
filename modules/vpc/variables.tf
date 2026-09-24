variable "name" {
  description = "Name prefix for the VPC and its subnets."
  type        = string
}

variable "cidr" {
  description = "IPv4 CIDR for the VPC. A /16 leaves room for /20 private and /24 public subnets."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.cidr))
    error_message = "cidr must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of Availability Zones. EKS requires at least two."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3. Two AZs is the dev default."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway so private subnets can reach the internet. About 0.045 USD per hour plus data and a public IPv4 address. Leave false for the cheap lab path (nodes on public subnets)."
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway for every AZ. Cheaper than one NAT per AZ, and a single point of failure. Dev only."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to VPC resources."
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Value for the karpenter.sh/discovery tag. Karpenter selects subnets and the node security group with this tag."
  type        = string
}
