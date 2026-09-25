terraform {
  required_version = "~> 1.12.0"

  # HCP Terraform replaces this block with a cloud block. See cloud.tf.example.
  # Do not enable it until you have an HCP organization and have run terraform login.
  # A cloud block and a backend block cannot both be set.
}

resource "terraform_data" "hcp_notes" {
  input = "Workspaces live in projects. This lab stays on the local backend."
}
