terraform {
  required_version = "~> 1.12.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}
