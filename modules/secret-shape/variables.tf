variable "password" {
  description = "Ephemeral password passed in from the caller. Terraform will not write this value to the plan or state."
  type        = string
  ephemeral   = true
  sensitive   = true
}
