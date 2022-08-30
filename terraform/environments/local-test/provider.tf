terraform {
  required_version = ">= 0.13.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.00"
    }

    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">=0.5"
    }
  }
}
