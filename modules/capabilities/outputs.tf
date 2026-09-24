output "capability_arn" {
  description = "ARN of the ACK capability."
  value       = aws_eks_capability.ack.arn
}

output "role_arn" {
  description = "IAM role assumed by the EKS capabilities service."
  value       = aws_iam_role.ack.arn
}

output "log_group_name" {
  description = "CloudWatch log group for ACK controller logs."
  value       = aws_cloudwatch_log_group.ack.name
}
