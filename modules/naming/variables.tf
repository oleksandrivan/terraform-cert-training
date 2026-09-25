variable "prefix" {
  description = "Short lowercase prefix for resource names. Keep it short so IAM and cluster names stay within AWS limits."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,16}$", var.prefix))
    error_message = "prefix must be 2-17 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name folded into the name prefix. Demonstrates module variable scope: each module call has its own value."
  type        = string

  validation {
    condition     = contains(["dev", "sandbox", "prod"], var.environment)
    error_message = "environment must be dev, sandbox, or prod."
  }
}

variable "extra_tags" {
  description = "Tags merged on top of the module defaults. Caller tags win on key collision."
  type        = map(string)
  default     = {}
}
