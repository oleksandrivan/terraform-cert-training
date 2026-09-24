variable "name" {
  description = "Cluster name. Also the Karpenter discovery tag value and the node IAM role name."
  type        = string
}

variable "cluster_endpoint" {
  description = "EKS API endpoint passed to the Karpenter chart. Comes from the EKS module output so the first apply can plan before the cluster exists."
  type        = string
}

variable "chart_version" {
  description = "Karpenter OCI chart version. 1.6.0 matches the terraform-aws-modules/eks karpenter example current with module 21.x."
  type        = string
  default     = "1.6.0"
}

variable "manage_manifests" {
  description = "Create the EC2NodeClass and NodePool from Terraform. Leave false on the first apply. The CRDs do not exist until the controller chart has installed them."
  type        = bool
  default     = false
}

variable "ecr_public_username" {
  description = "Public ECR user name for the Karpenter OCI chart."
  type        = string
  sensitive   = true
}

variable "ecr_public_password" {
  description = "Public ECR password for the Karpenter OCI chart."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags for AWS resources created for Karpenter."
  type        = map(string)
  default     = {}
}
