# Phase 4 — modules

Calls `modules/naming` twice. No AWS provider.

```bash
cd labs/04-modules
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Module tests live next to the module:

```bash
terraform -chdir=modules/naming init -backend=false
terraform -chdir=modules/naming test
```

Run that from the repository root.

Exam objectives: 5a, 5b, 5c. Objective 5d (version constraints) is the commented registry block in `main.tf` and the pinned modules in Phase 8.
