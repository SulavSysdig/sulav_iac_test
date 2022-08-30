############ Environment fixed configuration ############

data "aws_region" "current" {}

locals {
  cluster_name   = var.cluster_name
  cluster_region = data.aws_region.current.name
  cluster_admins = [
    {
      arn      = "arn:aws:iam::845151661675:user/alvaro.iradier"
      username = "alvaro.iradier"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/carlos.arilla"
      username = "carlos.arilla"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/jorge.salamero"
      username = "jorge.salamero"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/mateo.burillo"
      username = "mateo.burillo"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/fede.barcelona"
      username = "fede.barcelona"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/nestor.salceda"
      username = "nestor.salceda"
    },
    {
      arn      = "arn:aws:iam::845151661675:user/guillermo.palacio"
      username = "guillermo.palacio"
    }
  ]

  sysdig_region     = "us1"
  sysdig_access_key = var.sysdig_access_key

  kube_config            = yamldecode(module.cluster.kubeconfig)
  kube_config_with_token = yamldecode(module.cluster.kubeconfig_with_token)
}

############ EKS cluster ############

module "cluster" {
  source            = "../../modules/infra-cluster-eks"
  name              = local.cluster_name
  additional_admins = local.cluster_admins
  ssh_public_key    = var.ssh_public_key
  kubectl_platform  = var.kubectl_platform
  #TODO: this is for testing, use t2.large for demoenv
  instance_type = "t2.medium"
}

############ Helm scenarios, deployed in the cluster ############

provider "helm" {

  alias = "eks_cluster"

  kubernetes {
    host                   = local.kube_config_with_token.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kube_config_with_token.clusters[0].cluster.certificate-authority-data)
    token                  = local.kube_config_with_token.users[0].user.token
  }
}

provider "kubernetes" {
  alias                  = "local_cluster"
  host                   = local.kube_config_with_token.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kube_config_with_token.clusters[0].cluster.certificate-authority-data)
  token                  = local.kube_config_with_token.users[0].user.token
}

module "agent" {
  providers = {
    helm = helm.eks_cluster
  }

  source               = "../../modules/agent"
  cluster_name         = local.cluster_name
  sysdig_region        = local.sysdig_region
  sysdig_access_key    = local.sysdig_access_key
  deploy_node_analyzer = true

  values = [
    file("${path.module}/dragent.yaml"),
    <<EOT
resourceProfile: custom
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 2000m
    memory: 1536Mi
    EOT
    , <<EOT
nodeAnalyzer:
  deploy: true
  runtimeScanner:
    deploy: true
  imageAnalyzer:
    resources:
      requests:
        cpu: 50m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 1536Mi
  hostAnalyzer:
    resources:
      requests:
        cpu: 50m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 1536Mi
  benchmarkRunner:
    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi
    EOT
  ]

}

resource "helm_release" "example_voting_app" {
  provider = helm.eks_cluster

  name             = "example-voting-app"
  chart            = "${var.charts_path}/example-voting-app"
  namespace        = "example-voting-app"
  create_namespace = true
  atomic           = true
  timeout          = 600
}

resource "helm_release" "example_go_app" {
  provider = helm.eks_cluster

  name             = "example-go-app"
  chart            = "${var.charts_path}/example-go-app"
  namespace        = "example-go-app"
  create_namespace = true
  atomic           = true
  timeout          = 600
}

############ Log4j app scenario ############

module "log4japp" {
  source = "../../modules/log4j-app"
  providers = {
    helm       = helm.eks_cluster
    kubernetes = kubernetes.local_cluster
  }

  charts_path = var.charts_path
}

############ TODO: Cloudbench and others ############

# - name: cloud-bench
#   namespace: cloud-bench
#   chart: sysdig/cloud-bench
#   atomic: true
#   version: 0.1.0
#   needs: ["namespaces"]
#   values:
#     - sysdig:
#         secureApiToken: {{ requiredEnv "KUBE_SYSDIG_SECURE_API_KEY" }}
#       aws:
#         access_key_id: {{ requiredEnv "KUBE_AWS_ACCESS_KEY_ID" }}
#         secret_access_key: {{ requiredEnv "KUBE_AWS_SECRET_ACCESS_KEY" }}
#         region:  {{ requiredEnv "KUBE_AWS_REGION" }}
