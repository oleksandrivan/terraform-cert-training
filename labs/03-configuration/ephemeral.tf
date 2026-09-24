# Objective 4h — ephemeral values and write-only arguments.
#
# Sensitive variables are redacted in CLI output and still written to state
# when a managed resource stores them. Ephemeral values are not written to
# state or plan at all. Write-only arguments (suffix _wo, such as
# password_wo on aws_db_instance) are the place a managed resource accepts
# an ephemeral value. Bump the companion *_wo_version argument when the
# secret should rotate, because Terraform cannot diff a value it does not store.
#
# Vault: the Vault provider can read a secret at apply time. Prefer an
# ephemeral data source or ephemeral resource so the secret never lands in
# state. This repo does not run Vault.

ephemeral "random_password" "demo" {
  length           = 20
  special          = true
  override_special = "-_"
}

module "secret_shape" {
  source = "../../modules/secret-shape"

  # coalesce() might not be valid for ephemeral values if one branch is
  # ephemeral and the other is not. Both inputs here are ephemeral:
  # the variable is ephemeral, and the random_password result is ephemeral.
  password = var.demo_password != null ? var.demo_password : ephemeral.random_password.demo.result
}

# Sketch of a write-only argument. Not applied. An RDS instance is out of
# scope for a cheap lab, and password_wo is the pattern to copy:
#
# resource "aws_db_instance" "example" {
#   engine              = "postgres"
#   username            = "app"
#   password_wo         = module.secret_shape.password
#   password_wo_version = 1
#   skip_final_snapshot = true
# }
