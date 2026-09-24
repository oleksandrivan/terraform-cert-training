data "aws_ec2_managed_prefix_list" "lattice_ipv4" {
  count = var.enable_vpc_lattice ? 1 : 0
  name  = "com.amazonaws.${var.region}.vpc-lattice"
}

resource "aws_security_group" "lattice" {
  count = var.enable_vpc_lattice ? 1 : 0

  name        = "${var.name}-lattice"
  description = "Security group for the VPC Lattice service network association"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-lattice"
  })
}

resource "aws_vpc_security_group_ingress_rule" "lattice_from_prefix" {
  count = var.enable_vpc_lattice ? 1 : 0

  security_group_id = aws_security_group.lattice[0].id
  description       = "Health checks and traffic from VPC Lattice"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.lattice_ipv4[0].id
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "lattice_to_nodes" {
  count = var.enable_vpc_lattice ? 1 : 0

  security_group_id            = aws_security_group.lattice[0].id
  description                  = "Lattice to node workloads"
  referenced_security_group_id = var.node_security_group_id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_lattice" {
  count = var.enable_vpc_lattice ? 1 : 0

  security_group_id = var.node_security_group_id
  description       = "Allow VPC Lattice to reach pods"
  prefix_list_id    = data.aws_ec2_managed_prefix_list.lattice_ipv4[0].id
  ip_protocol       = "-1"
}

resource "aws_vpclattice_service_network" "this" {
  count = var.enable_vpc_lattice ? 1 : 0

  name      = "${var.name}-lattice"
  auth_type = "AWS_IAM"

  tags = var.tags
}

resource "aws_vpclattice_service_network_vpc_association" "this" {
  count = var.enable_vpc_lattice ? 1 : 0

  vpc_identifier             = var.vpc_id
  service_network_identifier = aws_vpclattice_service_network.this[0].id
  security_group_ids         = [aws_security_group.lattice[0].id]

  tags = var.tags
}

module "alb_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_alb_controller ? 1 : 0

  name                            = "${var.name}-alb"
  use_name_prefix                 = false
  attach_aws_lb_controller_policy = true

  associations = {
    controller = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = var.tags
}

resource "helm_release" "alb_controller" {
  count = var.enable_alb_controller ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.alb_chart_version
  namespace  = "kube-system"

  # One replica fits the single lab node. Leader election still works.
  wait    = true
  timeout = 600

  values = [
    yamlencode({
      clusterName  = var.cluster_name
      region       = var.region
      vpcId        = var.vpc_id
      replicaCount = 1
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [module.alb_pod_identity]
}

module "gateway_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_gateway_controller ? 1 : 0

  name                                 = "${var.name}-lattice-gw"
  use_name_prefix                      = false
  attach_aws_gateway_controller_policy = true

  associations = {
    controller = {
      cluster_name    = var.cluster_name
      namespace       = "aws-application-networking-system"
      service_account = "gateway-api-controller"
    }
  }

  tags = var.tags
}

resource "kubernetes_namespace_v1" "gateway" {
  count = var.enable_gateway_controller ? 1 : 0

  metadata {
    name = "aws-application-networking-system"
    labels = {
      "app.kubernetes.io/name" = "gateway-api-controller"
    }
  }
}

resource "kubernetes_service_account_v1" "gateway" {
  count = var.enable_gateway_controller ? 1 : 0

  metadata {
    name      = "gateway-api-controller"
    namespace = kubernetes_namespace_v1.gateway[0].metadata[0].name
  }
}

resource "helm_release" "gateway_controller" {
  count = var.enable_gateway_controller ? 1 : 0

  name       = "gateway-api-controller"
  repository = "oci://public.ecr.aws/aws-application-networking-k8s"
  chart      = "aws-gateway-controller-chart"
  version    = var.gateway_chart_version
  namespace  = kubernetes_namespace_v1.gateway[0].metadata[0].name

  repository_username = var.ecr_public_username
  repository_password = var.ecr_public_password

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      serviceAccount = {
        create = false
        name   = "gateway-api-controller"
      }
      log = {
        level = "info"
      }
    })
  ]

  depends_on = [
    module.gateway_pod_identity,
    kubernetes_service_account_v1.gateway,
  ]
}

resource "kubernetes_manifest" "gateway_class" {
  count = var.enable_gateway_controller && var.create_gateway_class ? 1 : 0

  manifest = yamldecode(file("${path.module}/manifests/gatewayclass.yaml"))

  depends_on = [helm_release.gateway_controller]
}
