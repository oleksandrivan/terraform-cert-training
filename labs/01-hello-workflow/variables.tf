variable "learner" {
  description = "Your first name or handle. Used only to make the generated pet id yours. Not sent anywhere."
  type        = string
  default     = "learner"
}

variable "message" {
  description = "String recorded by terraform_data. Changing it plans an update, which is the core workflow in miniature."
  type        = string
  default     = "Infrastructure as code: describe the result, let Terraform plan the diff."
}
