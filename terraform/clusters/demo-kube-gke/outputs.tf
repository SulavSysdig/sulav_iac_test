output "kubeconfig_with_token" {
  description = "Cluster kubeconfig using temporary token"
  value       = module.cluster.kubeconfig_with_token
  sensitive   = true
}

output "kubeconfig" {
  description = "Cluster kubeconfig use Google gcloud helper"
  value       = module.cluster.kubeconfig
  sensitive   = true
}
