output "cluster_name" {
  description = "Agent Cluster Name"
  value       = var.cluster_name
}

output "sysdig_region" {
  description = "Sysdig region (if not on-prem).\nCollector and API endpoints will be computed automatically from the region.\nMust be one of 'us1' | 'us2' | 'us3' | 'us4' | 'eu1' | 'au1'."
  value       = var.sysdig_region
}

output "sysdig_collector_endpoint" {
  description = "Sysdig collector endpoint"
  value       = var.sysdig_collector_endpoint
}

output "sysdig_collector_port" {
  description = "Sysdig collector port"
  value       = var.sysdig_collector_port
}

output "sysdig_access_key" {
  description = "Sysdig agent access key"
  value       = var.sysdig_access_key
  sensitive   = true
}

output "sysdig_onprem" {
  description = "Sysdig On-Prem (false for SaaS)"
  value       = var.sysdig_onprem
}

output "secure_api_endpoint" {
  description = "Sysdig Secure API endpoint"
  value       = var.secure_api_endpoint
}

output "resolved_secure_api_endpoint" {
  description = "Resolved Sysdig Secure API endpoint"
  value       = local.secure_api_endpoint
}

output "protoless_secure_api_endpoint" {
  description = "Protocol-less Sysdig Secure API endpoint"
  value       = local.protoless_secure_api_endpoint
}

output "resolved_sysdig_collector_endpoint" {
  description = "Resolved Sysdig collector endpoint"
  value       = local.sysdig_collector_endpoint
}
