# Phase 2 — providers and read-only state

Creates no AWS resources. `plan` and `apply` call the AWS API for data sources, which is free. State will contain the data source results. Do not commit `terraform.tfstate`.

Authenticate first (see the repository README). Then:

```bash
cd labs/02-providers
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

`terraform init` writes `.terraform.lock.hcl`. That lock file is committed in this repo after init so every clone uses the same provider builds. When you bump a constraint, run `terraform init -upgrade` and commit the lock.

Exam objectives: 2a, 2b, 2c, 2d, 4a.
