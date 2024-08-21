provider "aws" {
  region = var.aws_region
}

# Kubernetes provider for interacting with EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = "dr-strange-cluster"
}

