variable "name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version. 1.34 is in standard support as of September 2026. Confirm with aws eks describe-cluster-versions before apply. Extended support is about six times the control-plane price."
  type        = string
  default     = "1.34"
}

variable "vpc_id" {
  description = "VPC for the cluster security groups."
  type        = string
}

variable "control_plane_subnet_ids" {
  description = "Subnets for the EKS control-plane ENIs. At least two Availability Zones."
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "Subnets for the managed node group. Public subnets when NAT is off, private subnets when NAT is on."
  type        = list(string)
}

variable "enable_network_policy" {
  description = "Turn on the VPC CNI network policy agent (enableNetworkPolicy). Required before Kubernetes NetworkPolicy objects are enforced."
  type        = bool
  default     = false
}

variable "enable_cni_pod_identity" {
  description = "Associate the aws-node service account with a Pod Identity role that holds the VPC CNI policy. The node role still has the CNI policy until attach_cni_policy_to_node_role is set false."
  type        = bool
  default     = true
}

variable "attach_cni_policy_to_node_role" {
  description = "Attach AmazonEKS_CNI_Policy to the node IAM role. Leave true until Pod Identity for aws-node is healthy, then set false so nodes do not hold CNI permissions."
  type        = bool
  default     = true
}

variable "enabled_log_types" {
  description = "EKS control plane log types shipped to CloudWatch. Empty avoids log ingestion cost. The observability phase turns them on."
  type        = list(string)
  default     = []
}

variable "instance_types" {
  description = "Instance types for the small managed node group that runs system add-ons and the Karpenter controller."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired node count. Keep this at 1 for the lab."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum node count for the managed group. Karpenter scale-out is separate and capped in that module."
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Node root volume size in GiB."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags applied to cluster resources."
  type        = map(string)
  default     = {}
}
