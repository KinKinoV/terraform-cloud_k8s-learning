#####################################################################################
#                                     SSH key                                       #
#####################################################################################

output "key_data" {
  value = azapi_resource_action.ssh_public_key_gen.output.publicKey
}

#####################################################################################
#                                  Resource Group                                   #
#####################################################################################

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "resource_group_location" {
  value = azurerm_resource_group.this.location
}

#####################################################################################
#                                    Azure DNS                                      #
#####################################################################################

output "dns_zone_name" {
  value = azurerm_dns_zone.this.name
}

output "dns_zone_nameservers" {
  value = azurerm_dns_zone.this.name_servers
}

#####################################################################################
#                                    Kubernetes                                     #
#####################################################################################

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}