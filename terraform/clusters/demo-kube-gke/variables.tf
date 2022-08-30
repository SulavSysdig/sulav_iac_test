variable "sysdig_access_key" {
  description = "Sysdig agent access key"
  type        = string
  sensitive   = true
}

variable "charts_path" {
  description = "Path to the folder containing the internal charts"
  type        = string
}

variable "secure_api_token" {
  description = "Sysdig Secure API Token"
  type        = string
  sensitive   = true
}

variable "docker_repository_user" {
  description = "Jenkins Docker Repository User"
  type        = string
  sensitive   = true
}

variable "docker_repository_pass" {
  description = "Jenkins Docker Repository Password"
  type        = string
  sensitive   = true
}

variable "jenkins_user" {
  description = "Jenkins UI User"
  type        = string
  sensitive   = true
}

variable "jenkins_pass" {
  description = "Jenkins UI Password"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  type = string
}

variable "project" {
  type    = string
  default = "mateo-burillo-ns"
}

variable "existing_dns_zone_name" {
  description = "Name of the Cloud DNS zone to use (if it exists)"
  type        = string
  default     = null
}

variable "dns_zone" {
  description = "Name of the Cloud DNS zone to create"
  type        = string
  default     = null
}

variable "dns_suffix" {
  description = "Optionally, add a sufix to the DNS records (avoid collisions for tests in same DNS zone)"
  type        = string
  default     = ""
}
