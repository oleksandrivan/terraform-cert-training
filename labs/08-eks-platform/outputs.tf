output "account_id" {
  description = "Account Terraform is using. Not a secret. Confirm it before apply."
  value       = data.aws_caller_identity.current.account_id
}

output "name_prefix" {
  description = "Naming module output for this environment."
  value       = module.naming.name_prefix
}

output "vpc_id" {
  description = "VPC id when enable_vpc is true."
  value       = local.vpc_id != "" ? local.vpc_id : null
}

output "cluster_name" {
  description = "EKS cluster name when enable_eks is true."
  value       = local.cluster_name_or_empty != "" ? local.cluster_name_or_empty : null
}

output "update_kubeconfig_command" {
  description = "Run this after the cluster exists."
  value       = local.cluster_name_or_empty != "" ? "aws eks update-kubeconfig --name ${local.cluster_name_or_empty} --region ${var.aws_region}" : null
}

output "lab_bucket_name" {
  description = "Lab bucket name when enable_s3 is true."
  value       = try(module.storage[0].bucket_name, null)
}

output "karpenter_node_role" {
  description = "IAM role name referenced by the Karpenter EC2NodeClass."
  value       = try(module.karpenter[0].node_iam_role_name, null)
}

output "ack_capability_arn" {
  description = "ACK capability ARN when enable_capabilities is true."
  value       = try(module.capabilities[0].capability_arn, null)
}
