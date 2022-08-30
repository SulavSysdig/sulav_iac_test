output "kubeconfig" {
  description = "Cluster kubeconfig using client certificate"
  value       = local.kubeconfig
  sensitive   = true
}

output "kubeconfig_with_token" {
  description = "Cluster kubeconfig using short lived token"
  value       = local.kubeconfig
  sensitive   = true
}

