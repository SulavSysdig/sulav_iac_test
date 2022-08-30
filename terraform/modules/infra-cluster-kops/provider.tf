terraform {
  required_providers {
    kops = {
      source = "eddycharly/kops"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
  }
}
