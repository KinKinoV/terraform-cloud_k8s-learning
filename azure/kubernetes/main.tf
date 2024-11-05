provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  resource_group_name = var.rg_name
}

data "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.rg_name
}

data "azurerm_resource_group" "this" {
  name = var.rg_name
}

provider "kubernetes" {
  host = data.azurerm_kubernetes_cluster.this.kube_config.0.host

  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = data.azurerm_kubernetes_cluster.this.kube_config.0.host

    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
  }
}