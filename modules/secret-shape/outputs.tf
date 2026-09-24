output "password" {
  description = "Ephemeral output. Only valid in ephemeral contexts in the caller, such as a write-only argument."
  value       = var.password
  ephemeral   = true
  sensitive   = true
}
