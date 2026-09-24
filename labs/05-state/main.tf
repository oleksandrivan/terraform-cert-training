terraform {
  required_version = "~> 1.12.0"

  # No backend block means the local backend. Remote state is in backend.tf.example.
}

resource "terraform_data" "current_name" {
  input = "state-lab"
}

# First apply: the old address is not in state, so this block is a no-op.
# After you rename a resource, a moved block tells Terraform the state object
# moved rather than forcing a destroy and create.
moved {
  from = terraform_data.old_name
  to   = terraform_data.current_name
}
