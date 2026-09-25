terraform {
  required_version = "~> 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.35, < 3.0"
    }
  }
}
