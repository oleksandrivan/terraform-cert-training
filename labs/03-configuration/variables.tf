variable "topics" {
  description = "Map of objects. Complex types plus a for_each over the map."
  type = map(object({
    domain = number
    notes  = string
  }))
  default = {
    iac = {
      domain = 1
      notes  = "Describe the result, do not script the clicks."
    }
    workflow = {
      domain = 3
      notes  = "init, fmt, validate, plan, apply, destroy."
    }
    config = {
      domain = 4
      notes  = "variables, outputs, expressions, conditions."
    }
  }
}

variable "example_api_token" {
  description = "Sensitive variable. Terraform redacts it in plan output. It is still stored in state if a resource argument uses it. The default is a placeholder, not a credential. Never commit a real token in tfvars."
  type        = string
  sensitive   = true
  default     = "placeholder-not-a-secret"
}

variable "demo_password" {
  description = "Ephemeral input. Terraform 1.10+ will not write this value to state or plan. Leave null to let the lab generate one with an ephemeral random_password."
  type        = string
  default     = null
  ephemeral   = true
  sensitive   = true
}
