provider "sysdig" {
  sysdig_secure_api_token = var.secure_api_token
}

provider "aws" {
}

provider "google" {
  project = var.gcp-project
}

module "demo-kube-gke" {
  source       = "../../clusters/demo-kube-gke"
  cluster_name = "demo-staging-gke"
  project      = var.gcp-project

  charts_path            = "../../../charts"
  sysdig_access_key      = var.sysdig_access_key
  secure_api_token       = var.secure_api_token
  docker_repository_user = var.docker_repository_user
  docker_repository_pass = var.docker_repository_pass
  jenkins_user           = var.jenkins_user
  jenkins_pass           = var.jenkins_pass

  existing_dns_zone_name = "staging-gcp-sysdig-demo-zone" #Don't create a new zone, reuse existing one
  dns_suffix             = ""
}

module "demo-kube-eks" {
  source       = "../../clusters/demo-kube-eks"
  cluster_name = "demo-staging-eks"

  charts_path       = "../../../charts"
  sysdig_access_key = var.sysdig_access_key
  kubectl_platform  = var.kubectl_platform
}
