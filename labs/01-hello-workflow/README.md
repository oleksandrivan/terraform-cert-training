# Phase 1 — hello workflow

No AWS credentials. No cloud resources. State stays in this directory (`terraform.tfstate`, gitignored).

```bash
cd labs/01-hello-workflow
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Change `message` in `terraform.tfvars` (gitignored) or with `-var`, plan again, and read the diff. That is the whole core workflow.

Exam objectives: 1a, 1b, 1c, 3a–3g.
