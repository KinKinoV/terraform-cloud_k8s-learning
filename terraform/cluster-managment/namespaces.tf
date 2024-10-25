resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "hello-app" {
  metadata {
    name = "hello-app"
  }
}