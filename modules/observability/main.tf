data "aws_eks_addon_version" "cloudwatch" {
  addon_name         = "amazon-cloudwatch-observability"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

module "cloudwatch_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"

  name                                       = "${var.name}-cloudwatch"
  use_name_prefix                            = false
  attach_aws_cloudwatch_observability_policy = true

  associations = {
    agent = {
      cluster_name    = var.cluster_name
      namespace       = "amazon-cloudwatch"
      service_account = "cloudwatch-agent"
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "container_insights" {
  name              = "/aws/containerinsights/${var.cluster_name}/performance"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_eks_addon" "cloudwatch" {
  cluster_name                = var.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  addon_version               = data.aws_eks_addon_version.cloudwatch.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  # The add-on installs the CloudWatch agent and Fluent Bit and turns on
  # Container Insights with enhanced observability for EKS.
  depends_on = [
    module.cloudwatch_pod_identity,
    aws_cloudwatch_log_group.container_insights,
  ]

  tags = var.tags
}
