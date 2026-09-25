output "account_id" {
  description = "Account id from the caller identity data source. Data sources read; they do not create. The id is not a secret."
  value       = data.aws_caller_identity.current.account_id
}

output "primary_region" {
  description = "Region of the default provider."
  value       = data.aws_region.primary.region
}

output "secondary_region" {
  description = "Region of the aliased provider. Same account, different region configuration."
  value       = data.aws_region.secondary.region
}

output "availability_zones" {
  description = "AZs in the primary region. The VPC lab slices this list."
  value       = data.aws_availability_zones.available.names
}
