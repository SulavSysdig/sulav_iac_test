terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.4"
    }
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">=0.5"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.8"
    }
  }
}
