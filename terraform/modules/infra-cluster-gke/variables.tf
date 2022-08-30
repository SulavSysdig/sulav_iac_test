variable "name" {
  description = "Cluster name"
  type        = string
}

variable "node_count" {
  type    = number
  default = 2
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "image_type" {
  type    = string
  default = "ubuntu_containerd"
}
