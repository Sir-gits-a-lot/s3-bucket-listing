data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks]
  name = module.eks.cluster_name
}

data "aws_eks_cluster" "eks_cluster" {
  depends_on = [module.eks]
  name = module.eks.cluster_name
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
