provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}


# provider "kubernetes" {
#   host                   = module.eks.endpoint
#   cluster_ca_certificate = base64decode(module.eks.eks_cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.auth_token.token
# }

data "aws_eks_cluster_auth" "auth_token" {
  name = module.eks.cluster_name
}

resource "helm_release" "nginx-ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.0"

}