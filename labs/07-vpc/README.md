# Phase 7 — VPC

Standalone network lab. It does not create EKS. The default apply creates a VPC, subnets, an internet gateway, and a free S3 gateway endpoint. It does not create a NAT gateway.

Do not apply this and Phase 8 in the same account and region without noticing the names differ (`tf004-dev-net` here, `tf004-dev` there). Destroy whichever one you are not using.

```bash
cd labs/07-vpc
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

Cost: no NAT means no hourly NAT charge. You still have a VPC. Destroy it when you stop for the day.
