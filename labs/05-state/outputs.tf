output "recorded" {
  description = "Value stored in local state."
  value       = terraform_data.current_name.output
}
