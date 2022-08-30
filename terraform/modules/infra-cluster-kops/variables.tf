variable "ssh_public_key" {
  description = "Path to the SSH Public key file"
}

variable "name" {
  description = "Cluster name"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
}

variable "node_count" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "m5.large"
}


variable "master_type" {
  type    = string
  default = "m5.large"
}
