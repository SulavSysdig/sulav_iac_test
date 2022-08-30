locals {
  name            = var.name
  cluster_version = "1.21"
  instance_type   = var.instance_type
  location        = var.location

  tags = {
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

################################################################################
# AKS Module
################################################################################


resource "azurerm_resource_group" "default" {
  name     = "${local.name}-rg"
  location = local.location

  tags = local.tags
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = local.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${local.name}-k8s"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.instance_type
    #os_disk_size_gb = 30
  }

  #service_principal {
  #  client_id     = "" #var.appId
  #  client_secret = "" #var.password
  #}

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = local.tags
}
