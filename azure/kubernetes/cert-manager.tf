resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

#####################################################################################
#                                 Managed Identities                                #
#####################################################################################

resource "azurerm_user_assigned_identity" "cert-manager" {
  name                = "cert-manager"
  resource_group_name = var.rg_name
  location            = var.rg_location
}

resource "azurerm_federated_identity_credential" "cert-manager" {
  name                = "cert-manager"
  resource_group_name = var.rg_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.cert-manager.id
  subject             = "system:serviceaccount:${kubernetes_namespace.cert-manager.metadata[0].name}:cert-manager"
}

resource "azurerm_role_assignment" "cert-manager-dns-contributor" {
  scope                = data.azurerm_dns_zone.this.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.cert-manager.principal_id
}

#####################################################################################
#                                    Helm Chart                                     #
#####################################################################################

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  values = [<<EOT
crds:
  enabled: true
serviceAccount:
  labels:
    azure.workload.identity/use: "true"
podLabels:
  azure.workload.identity/use: "true"
  EOT
  ]
}

resource "kubernetes_manifest" "cluster-issuer" {
  depends_on = [ helm_release.cert-manager ]
  manifest = yamldecode(<<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.acme_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          ingressClassName: azure-application-gateway
  EOF
  )
}