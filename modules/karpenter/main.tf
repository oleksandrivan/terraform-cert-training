module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = var.name

  # The EC2NodeClass role field must be this exact name, not a prefixed random suffix.
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = var.name
  create_pod_identity_association = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = var.chart_version
  namespace  = "kube-system"

  repository_username = var.ecr_public_username
  repository_password = var.ecr_public_password

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      replicas = 1
      nodeSelector = {
        "karpenter.sh/controller" = "true"
      }
      dnsPolicy = "Default"
      settings = {
        clusterName       = var.name
        clusterEndpoint   = var.cluster_endpoint
        interruptionQueue = module.karpenter.queue_name
        enableZonalShift  = false
      }
      webhook = {
        enabled = false
      }
    })
  ]

  depends_on = [module.karpenter]
}

resource "kubernetes_manifest" "ec2nodeclass" {
  count = var.manage_manifests ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/manifests/ec2nodeclass.yaml.tftpl", {
    role         = module.karpenter.node_iam_role_name
    cluster_name = var.name
  }))

  depends_on = [helm_release.karpenter]
}

resource "kubernetes_manifest" "nodepool" {
  count = var.manage_manifests ? 1 : 0

  manifest = yamldecode(file("${path.module}/manifests/nodepool.yaml"))

  depends_on = [kubernetes_manifest.ec2nodeclass]
}
