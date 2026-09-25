output "service_network_id" {
  description = "VPC Lattice service network id, if created."
  value       = try(aws_vpclattice_service_network.this[0].id, null)
}

output "service_network_arn" {
  description = "VPC Lattice service network ARN, if created."
  value       = try(aws_vpclattice_service_network.this[0].arn, null)
}

output "alb_controller_role_arn" {
  description = "Pod Identity role for the AWS Load Balancer Controller."
  value       = try(module.alb_pod_identity[0].iam_role_arn, null)
}
