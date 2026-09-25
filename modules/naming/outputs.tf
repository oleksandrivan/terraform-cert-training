output "name_prefix" {
  description = "Prefix shared by resources in this environment, for example tf004-dev."
  value       = local.name_prefix
}

output "tags" {
  description = "Default tags for this module call. Scope is this call only; a second call with environment = prod does not see these tags."
  value       = local.tags
}
