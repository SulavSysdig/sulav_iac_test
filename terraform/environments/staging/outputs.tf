output "gke_kubeconfig_with_token" {
  description = "Cluster kubeconfig using temporary token"
  value       = module.demo-kube-gke.kubeconfig_with_token
  sensitive   = true
}

output "gke_kubeconfig" {
  description = "Cluster kubeconfig use AWS gcloud helper"
  value       = module.demo-kube-gke.kubeconfig
  sensitive   = true
}

output "eks_kubeconfig_with_token" {
  description = "Cluster kubeconfig using short lived token"
  value       = module.demo-kube-eks.kubeconfig_with_token
  sensitive   = true
}

output "eks_kubeconfig" {
  description = "Cluster kubeconfig use AWS CLI helper"
  value       = module.demo-kube-eks.kubeconfig
  sensitive   = true
}
