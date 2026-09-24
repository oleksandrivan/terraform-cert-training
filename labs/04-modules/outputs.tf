output "dev_prefix" {
  description = "Name prefix from the dev module call."
  value       = module.dev.name_prefix
}

output "prod_prefix" {
  description = "Name prefix from the prod module call. Independent of module.dev."
  value       = module.prod.name_prefix
}

output "prod_cost_center" {
  description = "Tag set only on the prod call, which shows module variable scope."
  value       = module.prod.tags["CostCenter"]
}
