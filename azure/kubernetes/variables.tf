variable "subscription_id" {
  description = "Subscription ID for the AKS deployment"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Tenant ID of the Azure subscription"
  type        = string
  sensitive   = true
}

variable "aks_name" {
  description = "Name of the required AKS cluster to manage"
  type        = string
}

variable "rg_name" {
  description = "Name of the resource group where AKS was created"
  type        = string
}

variable "rg_location" {
  description = "Location code for the Resource Group location"
  type        = string
  default     = "northeurope"
}

variable "dns_zone_name" {
  description = "Name of the Azure DNS zone to be managed by ExternalDNS"
  type        = string
}