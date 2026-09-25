variable "name" {
  description = "Name prefix for the capability role."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster that will host the capability."
  type        = string
}

variable "bucket_arn" {
  description = "Lab bucket the ACK capability role may manage. This is intentionally narrower than AdministratorAccess."
  type        = string
}

variable "log_retention_days" {
  description = "Retention for ACK controller logs delivered to CloudWatch."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags for the capability and its role."
  type        = map(string)
  default     = {}
}
