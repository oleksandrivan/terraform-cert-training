variable "name" {
  description = "Name prefix for the observability IAM role and log group."
  type        = string
}

variable "cluster_name" {
  description = "Cluster that receives the CloudWatch Observability add-on."
  type        = string
}

variable "kubernetes_version" {
  description = "Cluster Kubernetes version used to select the add-on build."
  type        = string
}

variable "log_retention_days" {
  description = "Retention for the Container Insights log group created alongside the add-on. Seven days limits a forgotten lab."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags for AWS resources."
  type        = map(string)
  default     = {}
}
