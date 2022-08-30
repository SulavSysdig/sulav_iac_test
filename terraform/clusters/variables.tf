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

variable "kubectl_platform" {
  default = "linux"
}
