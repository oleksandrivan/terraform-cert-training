output "node_iam_role_name" {
  description = "IAM role name Karpenter passes to EC2NodeClass."
  value       = module.karpenter.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "Karpenter node IAM role ARN."
  value       = module.karpenter.node_iam_role_arn
}

output "queue_name" {
  description = "SQS queue Karpenter reads for interruption events."
  value       = module.karpenter.queue_name
}
