variable "environment_name" {
  type        = string
  description = "Provide a name for the environment like 'demo-test', or 'myname-testing'. Cluster names will start with this name (i.e. demo-test-gke)"
}

variable "gcp-project" {
  type        = string
  description = "Name of the project in Google Cloud Platform"
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

variable "kubectl_platform" {
  type = string
}
