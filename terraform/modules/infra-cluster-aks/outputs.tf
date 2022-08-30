output "kubeconfig" {
  description = "Cluster kubeconfig"
  value       = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive   = true
}

output "kubeconfig_with_token" {
  description = "Cluster kubeconfig"
  value       = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive   = true
}

