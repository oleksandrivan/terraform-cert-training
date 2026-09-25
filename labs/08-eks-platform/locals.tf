locals {
  cluster_name = "${module.naming.name_prefix}-eks"

  need_ecr_public = var.enable_karpenter || var.enable_gateway_controller
  enable_storage  = var.enable_s3 || var.enable_ebs_csi || var.enable_efs || var.enable_s3_csi

  vpc_id             = try(module.vpc[0].vpc_id, "")
  private_subnet_ids = try(module.vpc[0].private_subnet_ids, [])
  public_subnet_ids  = try(module.vpc[0].public_subnet_ids, [])
  node_subnet_ids    = var.enable_nat_gateway ? local.private_subnet_ids : local.public_subnet_ids

  cluster_name_or_empty  = try(module.eks[0].cluster_name, "")
  cluster_name_for_exec  = local.cluster_name_or_empty != "" ? local.cluster_name_or_empty : "not-created"
  cluster_endpoint       = try(module.eks[0].cluster_endpoint, "https://127.0.0.1")
  cluster_ca_raw         = try(module.eks[0].cluster_certificate_authority_data, "")
  cluster_ca_certificate = local.cluster_ca_raw == "" ? base64decode(base64encode("placeholder")) : base64decode(local.cluster_ca_raw)
  node_security_group_id = try(module.eks[0].node_security_group_id, "")
  bucket_arn             = try(module.storage[0].bucket_arn, "")

  ecr_public_username = local.need_ecr_public ? data.aws_ecrpublic_authorization_token.token[0].user_name : ""
  ecr_public_password = local.need_ecr_public ? data.aws_ecrpublic_authorization_token.token[0].password : ""
}
