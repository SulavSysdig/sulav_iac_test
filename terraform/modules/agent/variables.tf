variable "chart_version" {
  description = "Version of the agent Helm charts"
  type        = string
  default     = "1.12.63"
}

variable "cluster_name" {
  description = "Agent Cluster Name"
  type        = string
}

variable "sysdig_region" {
  description = "Sysdig region (if not on-prem).\nCollector and API endpoints will be computed automatically from the region.\nMust be one of 'us1' | 'us2' | 'us3' | 'us4' | 'eu1' | 'au1'."
  type        = string
  default     = ""

  validation {
    condition     = (var.sysdig_region == "" || contains(["us1", "us2", "us3", "us4", "eu1", "au1"], var.sysdig_region))
    error_message = "Invalid region."
  }
}

variable "sysdig_collector_endpoint" {
  description = "Sysdig collector endpoint"
  type        = string
  default     = ""
}

variable "sysdig_collector_port" {
  description = "Sysdig collector port"
  type        = string
  default     = "6443"
}

variable "sysdig_access_key" {
  description = "Sysdig agent access key"
  type        = string
  sensitive   = true
}

variable "sysdig_onprem" {
  description = "Sysdig On-Prem (false for SaaS)"
  type        = bool
  default     = false
}

variable "secure_api_endpoint" {
  description = "Sysdig Secure API endpoint"
  type        = string
  default     = ""
}

variable "deploy_node_analyzer" {
  description = "Deploy the Node Analyzer component"
  type        = bool
  default     = true
}

variable "values" {
  description = "Additional values for the Agent helm chart"
  default     = null
}
