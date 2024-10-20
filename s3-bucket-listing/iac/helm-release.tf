# provider "kubernetes" {
#   host                   = module.eks.endpoint
#   cluster_ca_certificate = base64decode(module.eks.eks_cluster.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.auth_token.token
# }

resource "helm_release" "nginx-ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.0"

}