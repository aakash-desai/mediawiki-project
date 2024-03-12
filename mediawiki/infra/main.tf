resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags = {
    "environment" = "${var.env}",
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["172.29.56.0/21"]
  tags = {
    "environment" = "${var.env}",
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.29.60.0/22"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.aks_kubernetes_version
  dns_prefix          = "aks-${var.env}"

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  network_profile {
    network_plugin = "azure"
    network_mode   = null
    network_policy = "azure"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      api_server_authorized_ip_ranges
    ]
  }
  depends_on = [azurerm_subnet.subnet]

}

resource "azurerm_kubernetes_cluster_node_pool" "k8s_nodepool" {
  name                  = var.nodepool_name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_B4ms"
  node_count            = 1
  vnet_subnet_id        = azurerm_subnet.subnet.id
  os_type               = "Linux"
  enable_auto_scaling   = true
  max_count             = 10
  min_count             = 3
  max_pods              = 11

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
  depends_on = [azurerm_kubernetes_cluster.aks]
}
