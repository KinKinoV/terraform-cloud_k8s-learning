resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

#####################################################################################
#                                 Managed Identities                                #
#####################################################################################

resource "azurerm_user_assigned_identity" "external-dns" {
  name                = "external-dns"
  resource_group_name = var.rg_name
  location            = var.rg_location
}

resource "azurerm_federated_identity_credential" "external-dns" {
  name                = "external-dns"
  resource_group_name = var.rg_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.external-dns.id
  subject             = "system:serviceaccount:${kubernetes_namespace.external-dns.metadata[0].name}:external-dns"
}

resource "azurerm_role_assignment" "external-dns-contributor" {
  scope                = data.azurerm_dns_zone.this.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.external-dns.principal_id
}

resource "azurerm_role_assignment" "external-dns-rg-reader" {
  scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.external-dns.principal_id
}

#####################################################################################
#                                    Helm Chart                                     #
#####################################################################################

resource "kubernetes_secret" "external-dns-azure-cred" {
  metadata {
    name = "external-dns-azure"
    namespace = kubernetes_namespace.external-dns.metadata[0].name
  }
  type = "Opaque"
  data = {
    "azure.json" = <<EOT
{
  "tenantId": "${var.tenant_id}",
  "subscriptionId": "${var.subscription_id}",
  "resourceGroup": "${var.rg_name}",
  "useWorkloadIdentityExtension": true
}
    EOT
  }
}

resource "helm_release" "external-dns" {
  depends_on = [ kubernetes_secret.external-dns-azure-cred ]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.15.0"
  namespace  = kubernetes_namespace.external-dns.metadata[0].name

  values = [<<EOT
fullNameOverride: external-dns

serviceAccount:
  labels:
    azure.workload.identity/use: "true"
  annotations:
    azure.workload.identity/client-id: ${azurerm_user_assigned_identity.external-dns.client_id}

podLabels:
  azure.workload.identity/use: "true"

extraVolumes:
  - name: azure-config-file
    secret:
      secretName: external-dns-azure
extraVolumeMounts:
  - name: azure-config-file
    mountPath: /etc/kubernetes
    readOnly: true

provider:
  name: azure
  EOT
  ]
}