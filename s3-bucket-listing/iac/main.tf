resource "kubernetes_deployment" "s3_listing_deployment" {
  depends_on = [module.eks]

  metadata {
    name      = "s3-listing-deployment"
    namespace = "default"
    labels = {
      app = "s3-listing"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "s3-listing"
      }
    }

    template {
      metadata {
        labels = {
          app = "s3-listing"
        }
      }

      spec {
        container {
          name  = "s3-listing"
          image = "ttl.sh/s3-listing:24h"

          port {
            container_port = 5000
          }

          resources {
            limits = {
              memory = "128Mi"
              cpu    = "500m"
            }

            requests = {
              memory = "64Mi"
              cpu    = "250m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "s3_listing_service" {
  metadata {
    name      = "s3-listing"
    namespace = "default"
  }

  spec {
    selector = {
      app = "s3-listing"
    }

    port {
      port        = 5000
      target_port = 5000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_ingress_v1" "s3_listing_ingress" {
  metadata {
    name      = "s3-listing-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/elb.port": "5000"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = "s3-listing.io"

      http {
        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "s3-listing"
              port {
                number = 5000
              }
            }
          }
        }
      }
    }
  }
}



# resource "kubernetes_manifest" "deployment" {
#   manifest = yamldecode(data.local_file.deployment.content)
#     depends_on = [module.eks.cluster_endpoint]
# }

# resource "kubernetes_manifest" "service" {
#   manifest = yamldecode(data.local_file.service.content)
#   #   depends_on = [
#   #   module.eks
#   # ]
# }

# resource "kubernetes_manifest" "ingress" {
#   manifest = yamldecode(data.local_file.ingress.content)

#   # depends_on = [
#   #  module.eks
#   # ]
# }