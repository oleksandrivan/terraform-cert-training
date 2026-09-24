provider "aws" {
  region              = var.aws_region
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = module.naming.tags
  }
}

# ECR Public API lives in us-east-1 even when the cluster is in another region.
provider "aws" {
  alias               = "ecr_public"
  region              = "us-east-1"
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = module.naming.tags
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.cluster_endpoint
    cluster_ca_certificate = local.cluster_ca_certificate
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        local.cluster_name_for_exec,
        "--region",
        var.aws_region,
      ]
    }
  }
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = local.cluster_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      local.cluster_name_for_exec,
      "--region",
      var.aws_region,
    ]
  }
}
