output "kube_config" {
  description = "Base64 encoded kubeconfig"
  value       = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive   = true
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.app.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.aks_rg.name
}

output "cluster_location" {
  description = "Location of the AKS cluster"
  value       = azurerm_kubernetes_cluster.app.location
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.app.fqdn
} 