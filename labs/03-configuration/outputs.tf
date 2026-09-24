output "topic_names" {
  description = "Keys of the topics map after for_each."
  value       = sort([for name, topic in terraform_data.topic : name])
}

output "dependent_saw" {
  description = "Value the dependent resource read from terraform_data.base."
  value       = terraform_data.dependent.output
}

output "example_api_token" {
  description = "Sensitive output. Shown as (sensitive value) in the CLI. Still stored in state because it is not ephemeral."
  value       = var.example_api_token
  sensitive   = true
}
