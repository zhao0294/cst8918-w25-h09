variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "h09-aks-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "canadacentral"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "h09-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "h09aks"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Size of the VM for the default node pool"
  type        = string
  default     = "Standard_B2s"
} 