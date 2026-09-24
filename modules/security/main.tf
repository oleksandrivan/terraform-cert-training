locals {
  create_namespace = var.enable_pod_identity_demo || var.enable_network_policy
}

resource "kubernetes_namespace_v1" "demo" {
  count = local.create_namespace ? 1 : 0

  metadata {
    name = "demo"
    labels = {
      "app.kubernetes.io/name"      = "tf004-demo"
      "kubernetes.io/metadata.name" = "demo"
    }
  }
}

resource "kubernetes_service_account_v1" "demo" {
  count = var.enable_pod_identity_demo ? 1 : 0

  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo[0].metadata[0].name
  }
}

module "demo_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.9"
  count   = var.enable_pod_identity_demo ? 1 : 0

  name                 = "${var.name}-demo"
  use_name_prefix      = false
  attach_custom_policy = true

  policy_statements = [
    {
      sid    = "ReadLabBucket"
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
      ]
      resources = [
        var.bucket_arn,
        "${var.bucket_arn}/*",
      ]
    }
  ]

  associations = {
    demo = {
      cluster_name    = var.cluster_name
      namespace       = "demo"
      service_account = "demo"
    }
  }

  tags = var.tags
}

resource "kubernetes_deployment_v1" "demo" {
  count = var.enable_pod_identity_demo ? 1 : 0

  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo[0].metadata[0].name
    labels = {
      app = "demo"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "demo"
      }
    }

    template {
      metadata {
        labels = {
          app = "demo"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.demo[0].metadata[0].name

        container {
          name  = "pause"
          image = "registry.k8s.io/pause:3.10"

          resources {
            requests = {
              cpu    = "10m"
              memory = "16Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [module.demo_pod_identity]
}

resource "kubernetes_network_policy_v1" "default_deny" {
  count = var.enable_network_policy ? 1 : 0

  metadata {
    name      = "default-deny"
    namespace = kubernetes_namespace_v1.demo[0].metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy_v1" "allow_namespace_and_dns" {
  count = var.enable_network_policy ? 1 : 0

  metadata {
    name      = "allow-same-namespace-and-dns"
    namespace = kubernetes_namespace_v1.demo[0].metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {}
      }
    }

    egress {
      to {
        pod_selector {}
      }
    }

    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "kube-system"
          }
        }
        pod_selector {
          match_labels = {
            k8s-app = "kube-dns"
          }
        }
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
    }
  }
}
