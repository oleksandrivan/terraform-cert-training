# Phase 5 — state and day-2 maintenance

Local state. Nothing is created in AWS.

```bash
cd labs/05-state
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Inspect state:

```bash
terraform state list
terraform state show terraform_data.current_name
terraform plan -refresh-only
```

Verbose logs (objective 7c). The log can contain sensitive values. Do not commit it.

```bash
TF_LOG=info TF_LOG_PATH=tf.log terraform plan
rm -f tf.log
```

`TF_LOG` levels: `trace`, `debug`, `info`, `warn`, `error`.

Drift: change a resource outside Terraform, then `terraform plan` (refresh is part of plan) or `terraform plan -refresh-only` to update state without changing infrastructure.

CLI workspaces (`terraform workspace new dev`) are separate state files on one backend. They are not HCP Terraform workspaces. HCP workspaces are Phase 6.

Remote backend: apply `backend/bootstrap` if you want a real bucket, then follow `backend.tf.example`.

```bash
terraform destroy
```

Exam objectives: 6a–6d, 7a–7c.
