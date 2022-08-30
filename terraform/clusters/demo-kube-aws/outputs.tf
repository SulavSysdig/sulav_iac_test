output "cluster_kubeconfig" {
  description = "Kubeconfig to connect to the cluster"
  value       = module.cluster.kubeconfig
  sensitive   = true
}
