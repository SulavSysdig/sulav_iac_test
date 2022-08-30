variable "cluster_name" {
  type = string
}

variable "sysdig_access_key" {
  description = "Sysdig agent access key"
  type        = string
  sensitive   = true
}

variable "charts_path" {
  description = "Path to the folder containing the internal charts"
  type        = string
}
