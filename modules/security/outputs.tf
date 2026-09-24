output "demo_role_arn" {
  description = "Pod Identity role ARN for the demo service account."
  value       = try(module.demo_pod_identity[0].iam_role_arn, null)
}
