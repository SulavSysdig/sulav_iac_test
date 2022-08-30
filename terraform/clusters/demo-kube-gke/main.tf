############ Environment fixed configuration ############

locals {
  cluster_name = var.cluster_name
  project      = var.project

  #TODO: this is for testing, check if we need e2-standard-4 for demoenv or we are ok witht his size
  machine_type = "e2-standard-2"
  node_count   = 3

  sysdig_region     = "us1"
  sysdig_access_key = var.sysdig_access_key

  kube_config            = yamldecode(module.cluster.kubeconfig)
  kube_config_with_token = yamldecode(module.cluster.kubeconfig_with_token)

  dns_domain = trimsuffix(var.existing_dns_zone_name == "" ? google_dns_managed_zone.demoenv-zone.0.dns_name : data.google_dns_managed_zone.demoenv-zone.dns_name, ".")
}

output "cluster_kubeconfig" {
  description = "Kubeconfig to connect to the cluster"
  value       = module.cluster.kubeconfig
  sensitive   = true
}

############ GKE cluster ############

module "cluster" {
  source       = "../../modules/infra-cluster-gke"
  name         = local.cluster_name
  machine_type = local.machine_type
  node_count   = local.node_count
}


############ Helm scenarios, deployed in the cluster ############

provider "helm" {

  alias = "gke_cluster"

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
    helm = helm.gke_cluster
  }

  source               = "../../modules/agent"
  cluster_name         = local.cluster_name
  sysdig_region        = local.sysdig_region
  sysdig_access_key    = local.sysdig_access_key
  deploy_node_analyzer = true

  values = [
    file("${path.module}/dragent.yaml"),
    file("${path.module}/prometheus.yaml"),
    <<EOT
resourceProfile: custom
resources:
  requests:
    cpu: 50m
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
    resources:
      requests:
        cpu: 25m
        memory: 512Mi
  imageAnalyzer:
    resources:
      requests:
        cpu: 25m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 1536Mi
  hostAnalyzer:
    resources:
      requests:
        cpu: 25m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 1536Mi
  benchmarkRunner:
    resources:
      requests:
        cpu: 25m
        memory: 128Mi
      limits:
        cpu: 500m
        memory: 256Mi
    EOT
  ]
}

resource "helm_release" "traefik" {
  provider = helm.gke_cluster

  name             = "traefik"
  chart            = "traefik"
  repository       = "https://helm.traefik.io/traefik"
  version          = "10.24.0"
  namespace        = "traefik"
  create_namespace = true
  atomic           = true
  timeout          = 120

  values = [
    <<-EOT
      ports:
        web:
          redirectTo: websecure
        websecure:
          tls:
            enabled: true
            certResolver: letsencrypt
      certResolvers:
        letsencrypt:
          httpChallenge:
            entryPoint: "web"
          tlsChallenge: true
          storage: /data/acme.json
      # This is needed to prevent Let's encrypt issue when starting the pod
      # If pod is not ready soon, the probe will fail
      # See https://github.com/traefik/traefik/issues/8786
      readinessProbe:
        failureThreshold: 1
        periodSeconds: 1
        initialDelaySeconds: 1
        successThreshold: 1
        timeoutSeconds: 2
    EOT
  ]
}

#TODO: Migrate to Kubernetes manifest
resource "helm_release" "quotas" {
  provider = helm.gke_cluster

  name             = "quotas"
  repository       = "https://charts.helm.sh/incubator"
  chart            = "raw"
  namespace        = "sock-shop"
  create_namespace = true
  atomic           = true
  timeout          = 600

  values = [
    <<-EOT
      resources:
      - apiVersion: v1
        kind: ResourceQuota
        metadata:
          name: compute-resources
          namespace: sock-shop
        spec:
          hard:
            requests.cpu: "2"
            requests.memory: 3Gi
            limits.cpu: "10"
            limits.memory: 10Gi
            persistentvolumeclaims: "4"
            pods: "1000"
    EOT
  ]
}

# Temporarily disabled, need to check with david.detorres, they are working on a new version
# module "istio_monitoring" {
#   source      = "../../modules/istio-monitoring"
#   charts_path = var.charts_path
#   providers = {
#     helm = helm.gke_cluster
#   }
# }

module "jenkins" {
  source = "../../modules/jenkins"
  providers = {
    helm       = helm.gke_cluster
    kubernetes = kubernetes.local_cluster
  }
  secure_api_token       = var.secure_api_token
  docker_repository_user = var.docker_repository_user
  docker_repository_pass = var.docker_repository_pass
  jenkins_dns            = "jenkins${var.dns_suffix}.${local.dns_domain}"
  jenkins_user           = var.jenkins_user
  jenkins_pass           = var.jenkins_pass
}

#TODO:
#- ../../demoenv-scenarios/scenarios/grafana-sysdig.yaml
#- ../../demoenv-scenarios/scenarios/sock-shop-demo.yaml
#- ../../demoenv-scenarios/scenarios/yace-exporter-demo.yaml

############ DNS zone ############

resource "google_dns_managed_zone" "demoenv-zone" {
  count       = var.existing_dns_zone_name == "" ? 1 : 0
  name        = replace(var.dns_zone, ".", "-")
  dns_name    = "${var.dns_zone}."
  description = "Demo environment DNS zone for ${var.dns_zone}"
}

data "google_dns_managed_zone" "demoenv-zone" {
  name = var.existing_dns_zone_name
}

data "kubernetes_service" "traefik" {

  depends_on = [
    helm_release.traefik
  ]

  provider = kubernetes.local_cluster

  metadata {
    name      = "traefik"
    namespace = "traefik"
  }
}

resource "google_dns_record_set" "traefik" {
  name         = "traefik${var.dns_suffix}.${local.dns_domain}."
  type         = "A"
  ttl          = 300
  managed_zone = var.existing_dns_zone_name == "" ? google_dns_managed_zone.demoenv-zone.0.name : data.google_dns_managed_zone.demoenv-zone.name
  rrdatas      = [data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip]
}


resource "google_dns_record_set" "jenkins" {
  name         = "jenkins${var.dns_suffix}.${local.dns_domain}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = var.existing_dns_zone_name == "" ? google_dns_managed_zone.demoenv-zone.0.name : data.google_dns_managed_zone.demoenv-zone.name
  rrdatas      = ["traefik${var.dns_suffix}.${local.dns_domain}."]
}
