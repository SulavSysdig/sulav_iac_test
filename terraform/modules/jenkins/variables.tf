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
  description = "Jenkins default admin username"
  type        = string
}

variable "jenkins_pass" {
  description = "Jenkins default admin password"
  type        = string
  sensitive   = true
}

variable "jenkins_dns" {
  description = "DNS name to configure the ingress"
  type        = string
}
