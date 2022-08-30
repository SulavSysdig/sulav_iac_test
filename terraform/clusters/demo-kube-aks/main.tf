############ Environment fixed configuration ############

locals {
  cluster_name   = var.cluster_name
  cluster_region = "eastus"

  sysdig_region     = "us1"
  sysdig_access_key = var.sysdig_access_key

  kube_config            = yamldecode(module.cluster.kubeconfig)
  kube_config_with_token = yamldecode(module.cluster.kubeconfig_with_token)
}

############ AKS cluster ############

module "cluster" {
  source        = "../../modules/infra-cluster-aks"
  name          = local.cluster_name
  instance_type = "Standard_DS2_v2"
  location      = "eastus"
}

############ Helm scenarios, deployed in the cluster ############

provider "helm" {

  alias = "aks_cluster"

  kubernetes {

    host = local.kube_config_with_token.clusters[0].cluster.server
    #username               = local.kube_config_with_token.clusters[0].cluster.username
    #password               = local.kube_config_with_token.clusters[0].cluster.password
    #client_certificate     = local.kube_config_with_token.clusters[0].cluster.client_certificate
    #client_key             = local.kube_config_with_token.clusters[0].cluster.client_key
    cluster_ca_certificate = base64decode(local.kube_config_with_token.clusters[0].cluster.certificate-authority-data)
    token                  = local.kube_config_with_token.users[0].user.token
  }
}


module "agent" {
  providers = {
    helm = helm.aks_cluster
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

#TODO:
# - ../../demoenv-scenarios/scenarios/kubernetes-audit-log.yaml
# - ../../demoenv-scenarios/scenarios/crypto-mining-demo.yaml
# - ../../demoenv-scenarios/scenarios/terminal-shell-in-container.yaml
# - ../../demoenv-scenarios/scenarios/nginx-crashloop.yaml
# - ../../demoenv-scenarios/scenarios/suspicious-network-tool.yaml
# - ../../demoenv-scenarios/scenarios/sensitive-info-exfiltration.yaml
# - ../../demoenv-scenarios/scenarios/admission-controller.yaml
# - ../../demoenv-scenarios/scenarios/K8s-control-plane.yaml
# - ../../demoenv-scenarios/scenarios/yace-exporter-demo.yaml
# - ../../demoenv-scenarios/scenarios/nginx-ingress-controller.yaml

# - name: example-java-app
#   namespace: example-java-app
#   chart: ../../demoenv-scenarios/charts/example-java-app
#   atomic: true
#   needs: ["namespaces"]
#   values:
#   - cassandra:
#       resources:
#         requests:
#           cpu: 200m
#           memory: 512Mi
#         limits:
#           cpu: 1
#           memory: 1Gi
#     javaapp:
#       resources:
#         requests:
#           cpu: 100m
#           memory: 254Mi
#         limits:
#           cpu: 250m
#           memory: 512Mi
#     jclient:
#       resources:
#         requests:
#           cpu: 50m
#           memory: 64Mi
#         limits:
#           cpu: 100m
#           memory: 128Mi
#     mongo:
#       resources:
#         requests:
#           cpu: 50m
#           memory: 64Mi
#         limits:
#           cpu: 100m
#           memory: 128Mi
#     mongo_statsd:
#       resources:
#         requests:
#           cpu: 50m
#           memory: 64Mi
#         limits:
#           cpu: 100m
#           memory: 128Mi
#     redis:
#       resources:
#         requests:
#           cpu: 50m
#           memory: 64Mi
#         limits:
#           cpu: 100m
#           memory: 128Mi
