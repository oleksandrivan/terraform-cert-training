output "note" {
  description = "Reminder that this root is local until you opt into HCP Terraform."
  value       = terraform_data.hcp_notes.output
}
