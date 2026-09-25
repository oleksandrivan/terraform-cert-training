variable "name" {
  description = "Name prefix for Lattice and IAM resources."
  type        = string
}

variable "region" {
  description = "AWS region of the cluster."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name passed to the AWS Load Balancer Controller."
  type        = string
}

variable "vpc_id" {
  description = "VPC associated with the cluster and, when enabled, the Lattice service network."
  type        = string
}

variable "node_security_group_id" {
  description = "Node security group that must accept traffic from the VPC Lattice prefix list."
  type        = string
}

variable "enable_alb_controller" {
  description = "Install the AWS Load Balancer Controller with Pod Identity. The controller does not create a load balancer until you add an Ingress or Service."
  type        = bool
  default     = false
}

variable "alb_chart_version" {
  description = "Helm chart version from https://aws.github.io/eks-charts. Chart 1.14.x tracks controller 2.14.x."
  type        = string
  default     = "1.14.1"
}

variable "enable_vpc_lattice" {
  description = "Create a VPC Lattice service network and associate this VPC. Empty networks have little or no hourly charge; you pay when traffic flows."
  type        = bool
  default     = false
}

variable "enable_gateway_controller" {
  description = "Install the VPC Lattice Gateway API controller. Requires enable_vpc_lattice. Needs Helm and an ECR Public token."
  type        = bool
  default     = false
}

variable "gateway_chart_version" {
  description = "OCI chart version for aws-gateway-controller-chart."
  type        = string
  default     = "v2.1.3"
}

variable "create_gateway_class" {
  description = "Apply the amazon-vpc-lattice GatewayClass. Leave false on the first apply so the chart can install CRDs, then set true and apply again."
  type        = bool
  default     = false
}

variable "ecr_public_username" {
  description = "Public ECR token user name. Required only for the Gateway API controller OCI chart."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ecr_public_password" {
  description = "Public ECR token password. Write it only into the Helm provider for this apply. Marked sensitive so it stays out of CLI output."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags for AWS resources."
  type        = map(string)
  default     = {}
}
