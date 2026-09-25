# Phase 8 — EKS platform

This root composes the modules under `modules/`. Every expensive feature is off. `terraform plan` with no tfvars creates nothing, then reads your caller identity.

```bash
cd labs/08-eks-platform
terraform init
terraform fmt
terraform validate
terraform plan
```

Copy `terraform.tfvars.example` to `terraform.tfvars` and enable one phase at a time. `terraform.tfvars` is gitignored.

```bash
terraform apply
terraform destroy
```

Phases, in order:

| Phase | Flags | What you get |
| --- | --- | --- |
| A | `enable_vpc` | VPC, two AZs, public and private subnets, free S3 gateway endpoint. Nodes would use public subnets because NAT is off. |
| B | `enable_eks`, `acknowledge_eks_cost` | EKS 1.34, one t3.medium, VPC CNI, Pod Identity agent, CNI Pod Identity role. |
| C | `enable_alb_controller`, `enable_vpc_lattice` | Load balancer controller and a Lattice service network. Add `enable_gateway_controller` for the Gateway API controller, then `create_gateway_class` on a second apply. |
| D | `enable_s3`, `enable_ebs_csi`, `enable_efs`, `enable_s3_csi` | Lab bucket, EBS CSI + gp3, EFS, Mountpoint CSI. |
| E | `enable_karpenter`, `acknowledge_karpenter_cost` | Karpenter IAM, SQS, controller. Then `manage_karpenter_manifests` for a 4-vCPU on-demand pool. |
| F | `enable_network_policy`, `enable_pod_identity_demo` | Demo namespace, NetworkPolicies, pause pod, S3 read role. |
| G | `enable_observability` | Control plane logs and the CloudWatch Observability add-on. |
| H | `enable_capabilities` | ACK capability scoped to the lab bucket. |

Before `terraform destroy` with Karpenter manifests applied:

```bash
kubectl delete nodepool --all
kubectl delete ec2nodeclass --all
kubectl delete ingress --all -A
kubectl delete svc --all -A
```

Wait until `kubectl get node` shows only the managed node, then `terraform destroy`. ACK's delete policy is `RETAIN`: the capability is removed, and any AWS objects you created through ACK custom resources are not.
