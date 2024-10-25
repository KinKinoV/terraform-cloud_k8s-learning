resource "kubernetes_deployment" "helloweb" {
  metadata {
    name = "helloweb"
    labels = {
      app = "hello"
    }
    namespace = kubernetes_namespace.hello-app.metadata[0].name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app  = "hello"
        tier = "web"
      }
    }
    template {
      metadata {
        labels = {
          app  = "hello"
          tier = "web"
        }
      }
      spec {
        container {
          name              = "hello-app"
          image             = "paulbouwer/hello-kubernetes:1.10.1"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "helloapp_service" {
  metadata {
    name = "hello-app-svc"
    namespace = kubernetes_namespace.hello-app.metadata[0].name
  }
  spec {
    port {
      port        = 443
      protocol    = "TCP"
      target_port = 8080
    }
    selector = {
      app  = "hello"
      tier = "web"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "helloapp_ingress" {
  metadata {
    name      = "hello-app-ingress"
    namespace = kubernetes_namespace.hello-app.metadata[0].name
    annotations = {
      "cert-manager.io/cluster-issuer"                 = kubernetes_manifest.cluster-issuer.manifest.metadata.name
      "alb.ingress.kubernetes.io/scheme"               = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-port"     = "traffic-port"
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = "{\"Type\": \"redirect\", \"RedirectConfig\": { \"Protocol\": \"HTTPS\", \"Port\": \"443\", \"StatusCode\": \"HTTP_301\"}}"
    }
  }
  spec {
    tls {
      hosts       = ["helloapp.kinkinov.com"]
      secret_name = "hello-app-tls"
    }
    rule {
      host = "helloapp.kinkinov.com"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "hello-app-svc"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }
}