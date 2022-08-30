output "kubeconfig_with_token" {
  description = "Cluster kubeconfig using short lived token"
  value       = module.cluster.kubeconfig_with_token
  sensitive   = true
}

output "kubeconfig" {
  description = "Cluster kubeconfig use AWS CLI helper"
  value       = module.cluster.kubeconfig
  sensitive   = true
}
