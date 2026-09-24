# Phase 6 — HCP Terraform

The applied configuration is local. The HCP workflow is in `cloud.tf.example` so this directory still `init`s without an HCP token.

```bash
cd labs/06-hcp-terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

When you have an organization:

```bash
terraform login
```

Then follow `cloud.tf.example`. Workspaces belong to projects. That split is objective 8c and was not on the 003 exam.

Exam objectives: 8a, 8b, 8c, 8d.
