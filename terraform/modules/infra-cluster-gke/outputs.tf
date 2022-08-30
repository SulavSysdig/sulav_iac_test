locals {
  cluster_id = "gke-cluster-${google_container_cluster.cluster.project}-${google_container_cluster.cluster.location}-${google_container_cluster.cluster.name}"
}

output "kubeconfig_with_token" {
  description = "Cluster kubeconfig using temporary token"
  value = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = local.cluster_id
    clusters = [{
      name = local.cluster_id
      cluster = {
        certificate-authority-data = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
        server                     = "https://${google_container_cluster.cluster.endpoint}"
      }
    }]
    contexts = [{
      name = local.cluster_id
      context = {
        cluster = local.cluster_id
        user    = local.cluster_id
      }
    }]
    users = [{
      name = local.cluster_id
      user = {
        token = module.gke_auth.token
      }
    }]
  })
}

output "kubeconfig" {
  description = "Cluster kubeconfig use Google gcloud helper"
  value = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = local.cluster_id
    clusters = [{
      name = local.cluster_id
      cluster = {
        certificate-authority-data = google_container_cluster.cluster.master_auth.0.cluster_ca_certificate
        server                     = "https://${google_container_cluster.cluster.endpoint}"
      }
    }]
    contexts = [{
      name = local.cluster_id
      context = {
        cluster = local.cluster_id
        user    = local.cluster_id
      }
    }]
    users = [{
      name = local.cluster_id
      user = {
        auth-provider = {
          name = "gcp"
          config = {
            cmd-args   = "config config-helper --format=json"
            cmd-path   = "gcloud"
            expiry-key = "{.credential.token_expiry}"
            token-key  = "{.credential.access_token}"
          }
        }
      }
    }]
  })
}
