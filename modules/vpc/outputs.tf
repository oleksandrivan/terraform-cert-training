output "vpc_id" {
  description = "VPC id."
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR."
  value       = module.vpc.vpc_cidr_block
}

output "azs" {
  description = "Availability Zones actually used."
  value       = local.azs
}

output "private_subnet_ids" {
  description = "Private subnet ids. Use these for the EKS control plane and for nodes when a NAT gateway exists."
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet ids. Use these for nodes when NAT is disabled."
  value       = module.vpc.public_subnets
}

output "private_route_table_ids" {
  description = "Private route table ids."
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "Public route table ids."
  value       = module.vpc.public_route_table_ids
}
