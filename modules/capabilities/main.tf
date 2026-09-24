# EKS Capabilities run managed controllers (ACK, kro, Argo CD) outside the
# data plane. ACK is the practical lab: it does not need IAM Identity Center.
# Argo CD capabilities do, so this module does not create one.
#
# delete_propagation_policy = RETAIN means deleting the capability keeps
# AWS resources that ACK already created. This scaffold does not apply ACK
# custom resources. If you do, delete those AWS resources yourself.

data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["capabilities.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]
  }
}

resource "aws_iam_role" "ack" {
  name               = "${var.name}-ack"
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = var.tags
}

data "aws_iam_policy_document" "ack" {
  statement {
    sid    = "LabBucket"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
      "s3:DeleteObject",
    ]
    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "ack" {
  name   = "${var.name}-ack-s3"
  role   = aws_iam_role.ack.id
  policy = data.aws_iam_policy_document.ack.json
}

resource "aws_eks_capability" "ack" {
  cluster_name              = var.cluster_name
  capability_name           = "ack"
  type                      = "ACK"
  role_arn                  = aws_iam_role.ack.arn
  delete_propagation_policy = "RETAIN"

  tags = var.tags

  depends_on = [aws_iam_role_policy.ack]

  timeouts {
    create = "20m"
    delete = "20m"
  }
}

resource "aws_cloudwatch_log_group" "ack" {
  name              = "/aws/eks/${var.cluster_name}/capabilities/ack"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_delivery_source" "ack" {
  name         = "${var.name}-ack-logs"
  log_type     = "EKS_CAPABILITY_ACK_LOGS"
  resource_arn = aws_eks_capability.ack.arn
}

resource "aws_cloudwatch_log_delivery_destination" "ack" {
  name = "${var.name}-ack-logs"

  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.ack.arn
  }
}

resource "aws_cloudwatch_log_delivery" "ack" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.ack.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.ack.arn

  depends_on = [aws_eks_capability.ack]
}
