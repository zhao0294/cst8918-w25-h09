provider "azurerm" {
  features {}
  subscription_id = "83fb8d4d-37ec-4e26-9d37-e6c0e026f658"
}

resource "azurerm_resource_group" "aks_rg" {
  name     = "h09-aks-rg"
  location = "canadacentral"
}

resource "azurerm_kubernetes_cluster" "app" {
  name                = "h09-aks-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "h09aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = null # Use latest version
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive = true
}