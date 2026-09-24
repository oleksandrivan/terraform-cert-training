# Phase 3 — configuration language

No AWS resources. Covers variables, outputs, object types, `for` / `for_each`, `depends_on`, `lifecycle.create_before_destroy`, preconditions, `check` blocks, sensitive values, and ephemeral values.

```bash
cd labs/03-configuration
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

`example_api_token` is sensitive. A failed `check` warns and does not stop apply. A failed `validation` or `precondition` does stop apply.

Exam objectives: 4a–4h.
