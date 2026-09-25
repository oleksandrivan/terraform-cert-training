locals {
  bucket_name = "${var.name}-${var.account_id}-lab"
}

resource "aws_s3_bucket" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket        = local.bucket_name
  force_destroy = true

  # force_destroy lets `terraform destroy` delete a training bucket that
  # still has objects. Do not copy that into a bucket that holds real data.
  lifecycle {
    precondition {
      condition     = length(local.bucket_name) <= 63
      error_message = "S3 bucket name ${local.bucket_name} is longer than 63 characters. Shorten name_prefix."
    }
  }

  tags = merge(var.tags, {
    Name = local.bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.lab[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.lab]
}

resource "aws_s3_bucket_versioning" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.lab[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.lab[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.lab[0].id

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 3
    }
  }

  depends_on = [aws_s3_bucket_versioning.lab]
}

data "aws_iam_policy_document" "lab_bucket" {
  count = var.enable_s3 ? 1 : 0

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.lab[0].arn,
      "${aws_s3_bucket.lab[0].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "lab" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.lab[0].id
  policy = data.aws_iam_policy_document.lab_bucket[0].json

  depends_on = [aws_s3_bucket_public_access_block.lab]
}

data "aws_eks_addon_version" "ebs" {
  count = var.enable_ebs_csi ? 1 : 0

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

module "ebs_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_ebs_csi ? 1 : 0

  name                      = "${var.name}-ebs-csi"
  use_name_prefix           = false
  attach_aws_ebs_csi_policy = true

  associations = {
    controller = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = var.tags
}

resource "aws_eks_addon" "ebs" {
  count = var.enable_ebs_csi ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = data.aws_eks_addon_version.ebs[0].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.ebs_pod_identity]
}

resource "kubernetes_storage_class_v1" "gp3" {
  count = var.enable_ebs_csi ? 1 : 0

  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_addon.ebs]
}

resource "aws_security_group" "efs" {
  count = var.enable_efs ? 1 : 0

  name        = "${var.name}-efs"
  description = "NFS from EKS nodes to EFS mount targets"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-efs"
  })
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  count = var.enable_efs ? 1 : 0

  security_group_id            = aws_security_group.efs[0].id
  description                  = "NFS from EKS nodes"
  referenced_security_group_id = var.node_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
}

resource "aws_efs_file_system" "lab" {
  count = var.enable_efs ? 1 : 0

  creation_token   = "${var.name}-efs"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-efs"
  })
}

resource "aws_efs_mount_target" "lab" {
  for_each = var.enable_efs ? toset(var.subnet_ids) : toset([])

  file_system_id  = aws_efs_file_system.lab[0].id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs[0].id]
}

data "aws_eks_addon_version" "efs" {
  count = var.enable_efs ? 1 : 0

  addon_name         = "aws-efs-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

module "efs_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_efs ? 1 : 0

  name                      = "${var.name}-efs-csi"
  use_name_prefix           = false
  attach_aws_efs_csi_policy = true

  associations = {
    controller = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "efs-csi-controller-sa"
    }
  }

  tags = var.tags
}

resource "aws_eks_addon" "efs" {
  count = var.enable_efs ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-efs-csi-driver"
  addon_version               = data.aws_eks_addon_version.efs[0].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.efs_pod_identity]
}

resource "kubernetes_storage_class_v1" "efs" {
  count = var.enable_efs ? 1 : 0

  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.lab[0].id
    directoryPerms   = "700"
  }

  depends_on = [aws_eks_addon.efs, aws_efs_mount_target.lab]
}

data "aws_eks_addon_version" "s3" {
  count = var.enable_s3_csi ? 1 : 0

  addon_name         = "aws-mountpoint-s3-csi-driver"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

module "s3_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_s3_csi ? 1 : 0

  name                               = "${var.name}-s3-csi"
  use_name_prefix                    = false
  attach_mountpoint_s3_csi_policy    = true
  mountpoint_s3_csi_bucket_arns      = [aws_s3_bucket.lab[0].arn]
  mountpoint_s3_csi_bucket_path_arns = ["${aws_s3_bucket.lab[0].arn}/*"]

  associations = {
    controller = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "s3-csi-driver-sa"
    }
  }

  tags = var.tags
}

resource "aws_eks_addon" "s3" {
  count = var.enable_s3_csi ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "aws-mountpoint-s3-csi-driver"
  addon_version               = data.aws_eks_addon_version.s3[0].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.s3_csi_pod_identity]
}

check "s3_bucket_named" {
  assert {
    condition     = !var.enable_s3 || length(local.bucket_name) >= 3
    error_message = "Lab bucket name is too short."
  }
}
