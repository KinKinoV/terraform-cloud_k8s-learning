resource "kubernetes_namespace" "test_namespace" {
  metadata {
    name = "test-namespace"
  }
}