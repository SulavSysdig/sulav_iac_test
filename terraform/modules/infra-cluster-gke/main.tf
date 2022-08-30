resource "google_container_cluster" "cluster" {
  name                     = var.name
  initial_node_count       = 1
  remove_default_node_pool = true

  network_policy {
    enabled = true
  }

  #ip_allocation_policy {
  #  use_ip_aliases = var.use_ip_aliases
  #}

  monitoring_service = "none"
  logging_service    = "none"
}

resource "google_container_node_pool" "default" {
  name       = "default"
  cluster    = google_container_cluster.cluster.id
  node_count = var.node_count

  node_config {
    image_type   = var.image_type
    machine_type = var.machine_type
  }
}

module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  depends_on = [
    google_container_node_pool.default
  ]

  project_id           = google_container_cluster.cluster.project
  cluster_name         = google_container_cluster.cluster.name
  location             = google_container_cluster.cluster.location
  use_private_endpoint = true
}
