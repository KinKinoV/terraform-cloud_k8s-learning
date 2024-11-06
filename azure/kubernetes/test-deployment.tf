resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    replicas = 4
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name = "nginx"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-svc"
  }
  spec {
    port {
      port = 80
      protocol = "TCP"
      target_port = 80
    }
    selector = {
      app = "nginx"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "nginx-ingress" {
  metadata {
    name = "nginx-ingress"
    annotations = {
      "external-dns.alpha.kubernetes.io/hostname" = "server.kinkinov.com"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }
  spec {
    ingress_class_name = "azure-application-gateway"
    tls {
      hosts = [ "server.kinkinov.com" ]
      secret_name = "nginx-ingress-secret"
    }
    rule {
      host = "server.kinkinov.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nginx-svc"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}