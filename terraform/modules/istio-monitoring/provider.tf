terraform {
  required_version = ">= 0.13.1"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4"
    }
  }
}
