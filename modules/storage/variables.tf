variable "name" {
  description = "Name prefix for the bucket, file system, and IAM roles."
  type        = string
}

variable "account_id" {
  description = "Account id used to make the S3 bucket name globally unique. Not a secret."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster that receives CSI add-ons. Required when a CSI driver is enabled."
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Cluster Kubernetes version used to look up the latest compatible add-on."
  type        = string
  default     = "1.34"
}

variable "vpc_id" {
  description = "VPC for the EFS security group."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnets for EFS mount targets. One per Availability Zone."
  type        = list(string)
  default     = []
}

variable "node_security_group_id" {
  description = "Node security group allowed to mount EFS (NFS/2049)."
  type        = string
  default     = ""
}

variable "enable_s3" {
  description = "Create an encrypted, non-public lab bucket. Storage cost is pennies until you upload data."
  type        = bool
  default     = false
}

variable "enable_ebs_csi" {
  description = "Install the EBS CSI add-on with Pod Identity and a gp3 StorageClass."
  type        = bool
  default     = false
}

variable "enable_efs" {
  description = "Create an encrypted EFS file system, mount targets, the EFS CSI add-on, and a StorageClass. You pay for data stored."
  type        = bool
  default     = false
}

variable "enable_s3_csi" {
  description = "Install the Mountpoint for S3 CSI add-on with read access to the lab bucket. Does not create a PersistentVolume; see manifests/s3-static-pv.yaml."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for AWS resources."
  type        = map(string)
  default     = {}
}
