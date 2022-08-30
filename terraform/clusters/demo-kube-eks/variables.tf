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

variable "ssh_public_key" {
  description = "Path to SSH pub key file to provision the nodes"
  type        = string
  default     = null
}

variable "kubectl_platform" {
  default = "linux"
}
