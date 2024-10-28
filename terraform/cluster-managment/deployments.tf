resource "kubernetes_deployment" "google_echoserver" {
  metadata {
    name = "echoserver"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "echoserver"
      }
    }
    template {
      metadata {
        labels = {
          app = "echoserver"
        }
      }
      spec {
        container {
          image             = "gcr.io/google_containers/echoserver:1.4"
          image_pull_policy = "Always"
          name              = "echoserver"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "google_echoserver" {
  metadata {
    name = "echoserver"
  }
  spec {
    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    type = "NodePort"
    selector = {
      app = "echoserver"
    }
  }
}

resource "kubernetes_ingress_v1" "google_echoserver" {
  metadata {
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "external-dns.alpha.kubernetes.io/hostname" = "echoserver.kinkinov.com"
      "cert-manager.io/cluster-issuer"            = "letsencrypt-test"
    }
    name = "echoserver"
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/"
          backend {
            service {
              name = "echoserver"
              port {
                number = 80
              }
            }
          }
          path_type = "Prefix"
        }
      }
    }
    tls {
      hosts       = ["echoserver.kinkinov.com"]
      secret_name = "echoserver-secret"
    }
  }
}