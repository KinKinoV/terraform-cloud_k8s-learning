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

    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}