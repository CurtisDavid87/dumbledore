module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "dr-strange-cluster"
  cluster_version = "1.25"
  
  vpc_id          = aws_vpc.main_vpc.id
  subnet_ids      = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]  # Specify the subnet IDs for your cluster

  enable_irsa     = true  # Enable IAM Roles for Service Accounts
}

resource "aws_eks_node_group" "wizard_group" {
  cluster_name    = module.eks.cluster_name
  node_group_name = "wizard-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]  # Specify the subnet IDs for the nodes

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  remote_access {
    ec2_ssh_key = var.key_pair_name
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "kubernetes_deployment" "wiz_web_app" {
  metadata {
    name = "wiz-web-app"
    labels = {
      app = "wiz-web-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "wiz-web-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "wiz-web-app"
        }
      }

      spec {
        container {
          name  = "wiz-web-app"
          image = "930793302926.dkr.ecr.us-east-2.amazonaws.com/merlins-repo:latest"
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wiz_web_app_service" {
  metadata {
    name = "wiz-web-app-service"
  }

  spec {
    selector = {
      app = "wiz-web-app"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

