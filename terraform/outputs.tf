output "mongodb_master_public_ip" {
  value = aws_instance.mongo_master.public_ip
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

