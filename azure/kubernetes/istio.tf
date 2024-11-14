#####################################################################################
#                                    Namespaces                                     #
#####################################################################################

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio-ingress" {
  metadata {
    name = "istio-ingress"
  }
}

#####################################################################################
#                                    Helm Chart                                     #
#####################################################################################

resource "helm_release" "istio-base" {
  name       = "istio-base"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name

  values = [<<EOT
deafultRevision: default
  EOT
  ]
}

resource "helm_release" "istiod" {
  depends_on = [helm_release.istio-base]

  name       = "istiod"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name
  wait       = true
}

resource "helm_release" "istio-ingress" {
  depends_on = [helm_release.istio-base, helm_release.istiod]

  name       = "istio-ingress"
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio-ingress.metadata[0].name
}