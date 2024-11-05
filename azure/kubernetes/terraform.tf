terraform {
  required_version = "~> 1.9.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.8.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "2.0.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
  }
}