variable "name" {
  description = "Name prefix for the demo Pod Identity role."
  type        = string
}

variable "cluster_name" {
  description = "Cluster that receives the demo Pod Identity association."
  type        = string
}

variable "bucket_arn" {
  description = "Lab bucket the demo service account may list and read. Requires the storage phase."
  type        = string
}

variable "enable_pod_identity_demo" {
  description = "Create a demo namespace, service account, pause Deployment, and a Pod Identity role scoped to the lab bucket."
  type        = bool
  default     = false
}

variable "enable_network_policy" {
  description = "Create a default-deny NetworkPolicy plus a same-namespace and DNS allow. The VPC CNI add-on must have enableNetworkPolicy=true or these objects are stored and not enforced."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for the IAM role."
  type        = map(string)
  default     = {}
}
