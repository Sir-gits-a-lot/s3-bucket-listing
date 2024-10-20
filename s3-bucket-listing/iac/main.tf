provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.auth_token.token
}

data "local_file" "deployment" {
  filename = "${path.module}/kubernetes_manifests/deployment.yaml"
}

data "local_file" "service" {
  filename = "${path.module}/kubernetes_manifests/svc.yaml"
}

data "local_file" "ingress" {
  filename = "${path.module}/kubernetes_manifests/ingress.yaml"
}

resource "kubernetes_manifest" "deployment" {
  manifest = yamldecode(data.local_file.deployment.content)
    depends_on = [
    module.eks
  ]
}

resource "kubernetes_manifest" "service" {
  manifest = yamldecode(data.local_file.service.content)
    depends_on = [
    module.eks
  ]
}

resource "kubernetes_manifest" "ingress" {
  manifest = yamldecode(data.local_file.ingress.content)

  depends_on = [
   module.eks
  ]
}