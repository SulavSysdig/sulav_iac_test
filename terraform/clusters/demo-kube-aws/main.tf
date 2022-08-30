############ Environment fixed configuration ############

data "aws_region" "current" {}


locals {
  cluster_name   = var.cluster_name
  cluster_region = data.aws_region.current.name

  sysdig_region     = "us1"
  sysdig_access_key = var.sysdig_access_key

  kube_config            = yamldecode(module.cluster.kubeconfig)
  kube_config_with_token = yamldecode(module.cluster.kubeconfig_with_token)
}

############ AWS Kops cluster ############

provider "kops" {
  alias       = "aws_cluster"
  state_store = "s3://${var.kops_state_bucket_name}"
}

module "cluster" {
  source = "../../modules/infra-cluster-kops"
  name   = local.cluster_name
  #TODO: Use m5.large for final env
  instance_type      = "m5.large"
  master_type        = "m5.large"
  ssh_public_key     = var.ssh_public_key
  kubernetes_version = "1.23.8"

  providers = {
    kops = kops.aws_cluster
  }
}

############ Helm scenarios, deployed in the cluster ############

provider "helm" {

  alias = "aws_cluster"

  kubernetes {

    host                   = local.kube_config_with_token.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kube_config_with_token.clusters[0].cluster.certificate-authority-data)
    username               = local.kube_config_with_token.users[0].user.username
    password               = local.kube_config_with_token.users[0].user.password
    client_certificate     = base64decode(local.kube_config_with_token.users[0].user.client-certificate-data)
    client_key             = base64decode(local.kube_config_with_token.users[0].user.client-key-data)
  }
}

module "agent" {

  depends_on = [
    module.cluster
  ]

  providers = {
    helm = helm.aws_cluster
  }

  source               = "../../modules/agent"
  cluster_name         = local.cluster_name
  sysdig_region        = local.sysdig_region
  sysdig_access_key    = local.sysdig_access_key
  deploy_node_analyzer = false

  values = [
    file("${path.module}/dragent.yaml"),
    file("${path.module}/prometheus.yaml"),
    <<EOT
resourceProfile: custom
resources:
  requests:
    cpu: 600m
    memory: 512Mi
  limits:
    cpu: 2000m
    memory: 1536Mi
    EOT
    ,
    <<EOT
extraVolumes:
  volumes:
    - name: etcd-certificates
      hostPath:
        path: "/etc/kubernetes/pki/etcd-manager-main"
        type: DirectoryOrCreate
  mounts:
    - mountPath: /etc/kubernetes/pki/etcd-manager
      name: etcd-certificates
    EOT
    ,
    <<EOT
    EOT
  ]

}

#TODO:
#- ../../demoenv-scenarios/scenarios/kubernetes-audit-log.yaml
#- ../../demoenv-scenarios/scenarios/crypto-mining-demo.yaml
#- ../../demoenv-scenarios/scenarios/terminal-shell-in-container.yaml
#- ../../demoenv-scenarios/scenarios/nginx-crashloop.yaml
#- ../../demoenv-scenarios/scenarios/suspicious-network-tool.yaml
#- ../../demoenv-scenarios/scenarios/sensitive-info-exfiltration.yaml
#- ../../demoenv-scenarios/scenarios/admission-controller.yaml
#- ../../demoenv-scenarios/scenarios/K8s-control-plane.yaml
#- ../../demoenv-scenarios/scenarios/yace-exporter-demo.yaml
#- ../../demoenv-scenarios/scenarios/nginx-ingress-controller.yaml


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
