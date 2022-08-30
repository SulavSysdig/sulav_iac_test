#module "aws" {
#  source = "./demo-kube-aws"
#
#  cluster_name      = "demoenv-aws"
#  kubeconfig        = var.kubeconfig_aws
#  sysdig_access_key = var.sysdig_access_key
#}

module "eks" {
  source = "./demo-kube-eks"

  cluster_name      = "demoenv-eks"
  sysdig_access_key = var.sysdig_access_key
  charts_path       = var.charts_path
  kubectl_platform  = var.kubectl_platform
}

module "aks" {
  source = "./demo-kube-aks"

  cluster_name      = "demoenv-aks"
  sysdig_access_key = var.sysdig_access_key
  charts_path       = var.charts_path
}

module "gke" {
  source = "./demo-kube-gke"

  cluster_name           = "demoenv-gke"
  sysdig_access_key      = var.sysdig_access_key
  charts_path            = var.charts_path
  secure_api_token       = var.secure_api_token
  docker_repository_user = var.docker_repository_user
  docker_repository_pass = var.docker_repository_pass
}
