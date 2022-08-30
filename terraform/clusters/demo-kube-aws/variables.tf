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

variable "kops_state_bucket_name" {
  description = "Name of the AWS S3 bucket where configuration should be stored"
  type        = string
}
