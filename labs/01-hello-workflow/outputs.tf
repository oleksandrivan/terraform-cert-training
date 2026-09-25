output "pet" {
  description = "Generated id. Referencing random_pet.learner.id from terraform_data is a cross-resource reference (objective 4b) you will use again in later labs."
  value       = random_pet.learner.id
}

output "recorded_message" {
  description = "Value stored in state for terraform_data.hello."
  value       = terraform_data.hello.output["message"]
}
