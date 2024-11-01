# This code was created by following the tutorial here https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

#####################################################################################
#                                  Resource Group                                   #
#####################################################################################

resource "random_pet" "rg_name" {
  prefix = var.rg_name_prefix
}

resource "azurerm_resource_group" "this" {
  location = var.rg_location
  name     = random_pet.rg_name.id
}

#####################################################################################
#                                     SSH key                                       #
#####################################################################################

resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

#####################################################################################
#                                       AKS                                         #
#####################################################################################

resource "random_pet" "aks_name" {
  prefix = "cluster"
}

resource "random_pet" "aks_dns_prefix" {
  prefix = "dns"
}

resource "azurerm_kubernetes_cluster" "this" {
  location            = azurerm_resource_group.this.location
  name                = random_pet.aks_name.id
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = random_pet.aks_dns_prefix.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "primepool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }

  linux_profile {
    admin_username = var.node_username

    ssh_key {
      key_data = azapi_resource_action.ssh_public_key_gen.output.publicKey
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}