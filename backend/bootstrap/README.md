# Optional remote-state bootstrap

Creates an encrypted S3 bucket and, by default, a DynamoDB lock table. This root keeps **local** state. That is normal: the bucket cannot store its own state on first apply.

`prevent_destroy` is set on the bucket. Empty it and remove that lifecycle block before you destroy it.

```bash
cd backend/bootstrap
terraform init
terraform plan
terraform apply
```

Then point a lab at the bucket using `labs/05-state/backend.tf.example` and `terraform init -migrate-state`.

Destroy this stack last, and only after every other lab is back on a local backend or destroyed.
