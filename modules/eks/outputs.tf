output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 cluster CA certificate."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "Kubernetes version of the cluster."
  value       = module.eks.cluster_version
}

output "node_security_group_id" {
  description = "Security group attached to worker nodes. Karpenter and VPC Lattice rules target this group."
  value       = module.eks.node_security_group_id
}

output "cluster_security_group_id" {
  description = "EKS-managed cluster security group."
  value       = module.eks.cluster_security_group_id
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN. Pod Identity is preferred for new workloads; this remains for comparison."
  value       = module.eks.oidc_provider_arn
}

output "update_kubeconfig_command" {
  description = "Command that writes a kubeconfig context for this cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${data.aws_region.current.region}"
}

data "aws_region" "current" {}
