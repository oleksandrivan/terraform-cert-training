variable "aws_region" {
  description = "AWS region for this lab. VPC Lattice and the Gateway API controller are not in every region; us-east-1 is a safe default."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must look like us-east-1."
  }
}

variable "allowed_account_ids" {
  description = "Optional guard. When non-empty, Terraform refuses to plan against any other account. Leave empty to allow the account your AWS profile currently uses."
  type        = list(string)
  default     = []
}

variable "name_prefix" {
  description = "Short prefix passed into the naming module. Default keeps names like tf004-dev-eks."
  type        = string
  default     = "tf004"
}

variable "environment" {
  description = "Environment passed into the naming module. Use dev for this lab."
  type        = string
  default     = "dev"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. Prefer a version in standard support. As of September 2026 that includes 1.34, 1.35, and 1.36."
  type        = string
  default     = "1.34"
}

variable "vpc_cidr" {
  description = "CIDR for the lab VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Availability Zones for the VPC. EKS needs at least two."
  type        = number
  default     = 2
}

variable "enable_vpc" {
  description = "Create the VPC. Default false so a fresh clone plans zero infrastructure."
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Create a single NAT gateway for private subnets. About 0.045 USD per hour plus data processing and a public IPv4 charge."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_nat_gateway || (var.enable_vpc && var.acknowledge_nat_cost)
    error_message = "enable_nat_gateway requires enable_vpc = true and acknowledge_nat_cost = true."
  }
}

variable "acknowledge_nat_cost" {
  description = "Set true to allow enable_nat_gateway. Read the cost section in the repository README first."
  type        = bool
  default     = false
}

variable "enable_eks" {
  description = "Create the EKS cluster, a 1-node managed group, VPC CNI, and the Pod Identity agent. The control plane is about 0.10 USD per hour in standard support."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_eks || (var.enable_vpc && var.acknowledge_eks_cost)
    error_message = "enable_eks requires enable_vpc = true and acknowledge_eks_cost = true. The control plane is about 0.10 USD per hour."
  }
}

variable "acknowledge_eks_cost" {
  description = "Set true to allow enable_eks. This is the expensive step."
  type        = bool
  default     = false
}

variable "node_instance_types" {
  description = "Managed node group instance types. t3.medium is the smallest comfortable size once add-ons are installed."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = length(var.node_instance_types) > 0
    error_message = "Provide at least one instance type."
  }
}

variable "node_min_size" {
  description = "Managed node group minimum."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Managed node group maximum. Keep this small."
  type        = number
  default     = 2

  validation {
    condition     = var.node_max_size <= 3
    error_message = "node_max_size must be 3 or less in this training stack."
  }
}

variable "node_desired_size" {
  description = "Managed node group desired size."
  type        = number
  default     = 1

  validation {
    condition     = var.node_desired_size >= var.node_min_size && var.node_desired_size <= var.node_max_size
    error_message = "node_desired_size must sit between node_min_size and node_max_size."
  }
}

variable "enable_network_policy" {
  description = "Enable the VPC CNI network policy engine and install demo NetworkPolicy objects."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_network_policy || var.enable_eks
    error_message = "enable_network_policy requires enable_eks."
  }
}

variable "enable_alb_controller" {
  description = "Install the AWS Load Balancer Controller with Pod Identity. No load balancer is created until you add an Ingress or a LoadBalancer Service."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_alb_controller || var.enable_eks
    error_message = "enable_alb_controller requires enable_eks."
  }
}

variable "enable_vpc_lattice" {
  description = "Create a VPC Lattice service network and associate the cluster VPC."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_vpc_lattice || var.enable_eks
    error_message = "enable_vpc_lattice requires enable_eks (and therefore enable_vpc)."
  }
}

variable "enable_gateway_controller" {
  description = "Install the VPC Lattice Gateway API controller. Requires enable_vpc_lattice."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_gateway_controller || var.enable_vpc_lattice
    error_message = "enable_gateway_controller requires enable_vpc_lattice."
  }
}

variable "create_gateway_class" {
  description = "Apply the amazon-vpc-lattice GatewayClass. Set this true only on a second apply, after the controller CRDs exist."
  type        = bool
  default     = false

  validation {
    condition     = !var.create_gateway_class || var.enable_gateway_controller
    error_message = "create_gateway_class requires enable_gateway_controller."
  }
}

variable "enable_s3" {
  description = "Create the encrypted lab bucket. Cheap. Required for the demo Pod Identity role, Mountpoint CSI, and the ACK capability."
  type        = bool
  default     = false
}

variable "enable_ebs_csi" {
  description = "Install the EBS CSI driver and a gp3 StorageClass."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_ebs_csi || var.enable_eks
    error_message = "enable_ebs_csi requires enable_eks."
  }
}

variable "enable_efs" {
  description = "Create EFS, mount targets, the EFS CSI driver, and a StorageClass. You pay for bytes stored."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_efs || var.enable_eks
    error_message = "enable_efs requires enable_eks."
  }
}

variable "enable_s3_csi" {
  description = "Install the Mountpoint for S3 CSI driver. A sample PersistentVolume is in modules/storage/manifests and is not applied automatically."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_s3_csi || (var.enable_eks && var.enable_s3)
    error_message = "enable_s3_csi requires enable_eks and enable_s3."
  }
}

variable "enable_karpenter" {
  description = "Install Karpenter's IAM, interruption queue, and controller. Nodes are not created until manage_karpenter_manifests is true and something unschedulable asks for them."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_karpenter || (var.enable_eks && var.acknowledge_karpenter_cost)
    error_message = "enable_karpenter requires enable_eks and acknowledge_karpenter_cost = true."
  }
}

variable "acknowledge_karpenter_cost" {
  description = "Set true to allow enable_karpenter. Karpenter can launch EC2 instances outside the managed node group."
  type        = bool
  default     = false
}

variable "manage_karpenter_manifests" {
  description = "Create the dev NodePool and EC2NodeClass. Leave false until the Karpenter chart has installed its CRDs."
  type        = bool
  default     = false

  validation {
    condition     = !var.manage_karpenter_manifests || var.enable_karpenter
    error_message = "manage_karpenter_manifests requires enable_karpenter."
  }
}

variable "enable_pod_identity_demo" {
  description = "Create the demo namespace, service account, pause pod, and an S3 read Pod Identity role."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_pod_identity_demo || (var.enable_eks && var.enable_s3)
    error_message = "enable_pod_identity_demo requires enable_eks and enable_s3."
  }
}

variable "enable_observability" {
  description = "Turn on EKS control plane logs and the CloudWatch Observability add-on (Container Insights). Log and metric ingestion is billed."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_observability || var.enable_eks
    error_message = "enable_observability requires enable_eks."
  }
}

variable "enable_capabilities" {
  description = "Create an EKS Capability of type ACK, scoped to the lab bucket, plus controller log delivery. delete_propagation_policy is RETAIN."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_capabilities || (var.enable_eks && var.enable_s3)
    error_message = "enable_capabilities requires enable_eks and enable_s3."
  }
}
