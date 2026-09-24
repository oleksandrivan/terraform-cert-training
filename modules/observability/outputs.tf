output "addon_arn" {
  description = "ARN of the CloudWatch Observability add-on."
  value       = aws_eks_addon.cloudwatch.arn
}

output "log_group_name" {
  description = "Container Insights performance log group."
  value       = aws_cloudwatch_log_group.container_insights.name
}
