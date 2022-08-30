variable "chart_version" {
  description = "Version of the Helm charts"
  type        = string
  default     = "0.5.16"
}

variable "charts_path" {
  description = "Path to the folder containing the internal charts"
  type        = string
}

variable "cluster_name" {
  description = "Agent Cluster Name"
  type        = string
}

variable "sysdig_access_key" {
  description = "Sysdig agent access key"
  type        = string
  sensitive   = true
}

variable "secure_api_token" {
  description = "Sysdig Secure API Token"
  type        = string
  sensitive   = true
}

variable "secure_api_endpoint" {
  description = "Sysdig Secure API endpoint"
  type        = string
  validation {
    condition     = can(regex("^https://", var.secure_api_endpoint))
    error_message = "Invalid value for secure_api_endpoint."
  }
}

variable "values" {
  description = "Additional values for the helm chart"
  default     = null
}
