output "vpc_id" {
  description = "VPC id."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets. Phase 8 uses these for nodes when NAT is off."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnets. No internet route unless enable_nat_gateway is true."
  value       = module.vpc.private_subnet_ids
}
