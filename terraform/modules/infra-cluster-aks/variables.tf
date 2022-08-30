variable "name" {
  description = "Cluster name"
  type        = string
}

variable "location" {
  description = "Resource group and cluster location"
  type        = string
}

variable "node_count" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "Standard_DS2_v2"
}
