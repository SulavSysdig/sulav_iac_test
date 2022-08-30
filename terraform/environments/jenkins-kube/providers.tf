provider "google" {
  project = "mateo-burillo-ns"
}

data "google_container_cluster" "cluster" {
  name     = "demo-kube-gke"
  location = "us-central1-a"
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  depends_on = [
    data.google_container_cluster.cluster
  ]

  project_id           = data.google_container_cluster.cluster.project
  cluster_name         = data.google_container_cluster.cluster.name
  location             = data.google_container_cluster.cluster.location
  use_private_endpoint = true
}

provider "helm" {

  kubernetes {
    host                   = "https://${data.google_container_cluster.cluster.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
    token                  = module.gke_auth.token
  }
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
  token                  = module.gke_auth.token
}
