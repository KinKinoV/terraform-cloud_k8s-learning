variable "subscription_id" {
  description = "Subscription ID for this deployment"
  type        = string
}

variable "rg_name_prefix" {
  description = "Prefix for the Resource Group random name"
  type        = string
  default     = "rg"
}

variable "rg_location" {
  description = "Location for the Resource Group to be created"
  type        = string
}

variable "node_count" {
  description = "Ammount of nodes for the default AKS node pool"
  type        = number
  default     = 3
}

variable "node_username" {
  description = "Admin username for the nodes' OS"
  type        = string
  default     = "azureadmin"
}