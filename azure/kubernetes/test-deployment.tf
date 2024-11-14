# Copyright Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

#############################################################################################
# This file defines the services, service accounts, and deployments for the Bookinfo sample.#
#############################################################################################

resource "kubernetes_namespace" "bookinfo" {
  depends_on = [ helm_release.istio-base, helm_release.istiod, helm_release.istio-ingress ]
  metadata {
    name = "bookinfo"
    labels = {
      istio-injection = "enabled"
    }
  }
}

#####################################################################################
#                                 Details Service                                   #
#####################################################################################

resource "kubernetes_service_account" "bookinfo-details" {
  metadata {
    name = "bookinfo-details"
    labels = {
      account = "details"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
}

resource "kubernetes_deployment" "details" {
  metadata {
    name = "details-v1"
    labels = {
      app     = "details"
      version = "v1"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "details"
        version = "v1"
      }
    }
    template {
      metadata {
        labels = {
          app     = "details"
          version = "v1"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-details.metadata[0].name
        container {
          name              = "details"
          image             = "docker.io/istio/examples-bookinfo-details-v1:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "details" {
  metadata {
    name = "details"
    labels = {
      app     = "details"
      service = "details"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    port {
      port = 9080
      name = "http"
    }
    selector = {
      app = "details"
    }
  }
}

#####################################################################################
#                                 Ratings Service                                   #
#####################################################################################

resource "kubernetes_service_account" "bookinfo-ratings" {
  metadata {
    name = "bookinfo-ratings"
    labels = {
      account = "ratings"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
}

resource "kubernetes_deployment" "ratings" {
  metadata {
    name = "ratings-v1"
    labels = {
      app     = "ratings"
      version = "v1"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "ratings"
        version = "v1"
      }
    }
    template {
      metadata {
        labels = {
          app     = "ratings"
          version = "v1"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-ratings.metadata[0].name
        container {
          name              = "ratings"
          image             = "docker.io/istio/examples-bookinfo-ratings-v1:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ratings" {
  metadata {
    name = "ratings"
    labels = {
      app     = "ratings"
      service = "ratings"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    port {
      port = 9080
      name = "http"
    }
    selector = {
      app = "ratings"
    }
  }
}

#####################################################################################
#                                 Reviews Service                                   #
#####################################################################################

resource "kubernetes_service_account" "bookinfo-reviews" {
  metadata {
    name = "bookinfo-reviews"
    labels = {
      account = "reviews"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
}

resource "kubernetes_deployment" "reviews-v1" {
  metadata {
    name = "reviews-v1"
    labels = {
      app     = "reviews"
      version = "v1"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "reviews"
        version = "v1"
      }
    }
    template {
      metadata {
        labels = {
          app     = "reviews"
          version = "v1"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-reviews.metadata[0].name
        container {
          name              = "reviews"
          image             = "docker.io/istio/examples-bookinfo-reviews-v1:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "wlp-output"
            mount_path = "/opt/ibm/wlp/output"
          }
        }
        volume {
          name = "wlp-output"
          empty_dir {}
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_deployment" "reviews-v2" {
  metadata {
    name = "reviews-v2"
    labels = {
      app     = "reviews"
      version = "v2"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "reviews"
        version = "v2"
      }
    }
    template {
      metadata {
        labels = {
          app     = "reviews"
          version = "v2"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-reviews.metadata[0].name
        container {
          name              = "reviews"
          image             = "docker.io/istio/examples-bookinfo-reviews-v2:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "wlp-output"
            mount_path = "/opt/ibm/wlp/output"
          }
        }
        volume {
          name = "wlp-output"
          empty_dir {}
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_deployment" "reviews-v3" {
  metadata {
    name = "reviews-v3"
    labels = {
      app     = "reviews"
      version = "v3"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "reviews"
        version = "v3"
      }
    }
    template {
      metadata {
        labels = {
          app     = "reviews"
          version = "v3"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-reviews.metadata[0].name
        container {
          name              = "reviews"
          image             = "docker.io/istio/examples-bookinfo-reviews-v3:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
          env {
            name  = "LOG_DIR"
            value = "/tmp/logs"
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
          volume_mount {
            name       = "wlp-output"
            mount_path = "/opt/ibm/wlp/output"
          }
        }
        volume {
          name = "wlp-output"
          empty_dir {}
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "reviews" {
  metadata {
    name = "reviews"
    labels = {
      app     = "reviews"
      service = "reviews"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    port {
      port = 9080
      name = "http"
    }
    selector = {
      app = "reviews"
    }
  }
}

#####################################################################################
#                                Productpage Service                                #
#####################################################################################

resource "kubernetes_service_account" "bookinfo-productpage" {
  metadata {
    name = "bookinfo-productpage"
    labels = {
      account = "productpage"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
}

resource "kubernetes_deployment" "productpage" {
  metadata {
    name = "productpage-v1"
    labels = {
      app     = "productpage"
      version = "v1"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app     = "productpage"
        version = "v1"
      }
    }
    template {
      metadata {
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "9080"
          "prometheus.io/path"   = "/metrics"
        }
        labels = {
          app     = "productpage"
          version = "v1"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.bookinfo-productpage.metadata[0].name
        container {
          name              = "productpage"
          image             = "docker.io/istio/examples-bookinfo-productpage-v1:1.20.2"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 9080
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service" "productpage" {
  metadata {
    name = "productpage"
    labels = {
      app     = "productpage"
      service = "productpage"
    }
    namespace = kubernetes_namespace.bookinfo.metadata[0].name
  }
  spec {
    port {
      port = 9080
      name = "http"
    }
    selector = {
      app = "productpage"
    }
  }
}

#####################################################################################
#                                  Istio Resources                                  #
#####################################################################################

# Deploy these resources after ClusterIssuer was deployed by Terraform

# # MUST BE deployed to the same namespace as istio-ingress helm chart
# resource "kubernetes_manifest" "bookinfo-cert" {
#   manifest = yamldecode(<<EOT
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: bookinfo-cert
#   namespace: ${kubernetes_namespace.istio-ingress.metadata[0].name}
# spec:
#   secretName: bookinfo-wildcard-tls
#   issuerRef:
#     name: ${kubernetes_manifest.cluster-issuer-dns.object.metadata.name}
#     kind: ${kubernetes_manifest.cluster-issuer-dns.object.kind}
#   commonName: "*.${var.dns_zone_name}"
#   dnsNames:
#   - '${var.dns_zone_name}'
#   - "*.${var.dns_zone_name}"
#   EOT
#   )
# }

# resource "kubernetes_manifest" "bookinfo-gateway" {
#   manifest = yamldecode(<<EOT
# apiVersion: networking.istio.io/v1
# kind: Gateway
# metadata:
#   name: bookinfo-gateway
#   namespace: ${kubernetes_namespace.bookinfo.metadata[0].name}
# spec:
#   selector:
#     istio: ingress
#   servers:
#   - port:
#       number: 80
#       name: http
#       protocol: HTTP
#     hosts:
#     - "bookinfo.${var.dns_zone_name}"
#     tls:
#       httpsRedirect: true
#   - port:
#       number: 443
#       name: https-443
#       protocol: HTTPS
#     hosts:
#     - "bookinfo.${var.dns_zone_name}"
#     tls:
#       mode: SIMPLE
#       credentialName: ${kubernetes_manifest.bookinfo-cert.object.spec.secretName}
#   EOT
#   )
# }

# resource "kubernetes_manifest" "bookinfo-virtual-svc" {
#   manifest = yamldecode(<<EOT
# apiVersion: networking.istio.io/v1
# kind: VirtualService
# metadata:
#   name: bookinfo
#   namespace: ${kubernetes_namespace.bookinfo.metadata[0].name}
# spec:
#   hosts:
#   - "bookinfo.${var.dns_zone_name}"
#   gateways:
#   - ${kubernetes_namespace.bookinfo.metadata[0].name}/${kubernetes_manifest.bookinfo-gateway.object.metadata.name}
#   http:
#   - match:
#     - uri:
#         exact: /productpage
#     - uri:
#         prefix: /static
#     - uri:
#         exact: /login
#     - uri:
#         exact: /logout
#     - uri:
#         prefix: /api/v1/products
#     route:
#     - destination:
#         host: productpage
#         port:
#           number: 9080
#   EOT
#   )
# }