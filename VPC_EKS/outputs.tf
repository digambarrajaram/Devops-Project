output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  value = var.eks_cluster_name
  description = "The name of the EKS cluster"
}

output "eks_cluster_arn" {
  value       = module.eks.eks_cluster_arn
  description = "The ARN of the EKS cluster"
}

output "endpoint" {
  value       = module.eks.endpoint
  description = "The endpoint of the EKS cluster"
}

output "ecr_repo_url"{
  value = module.ecr.ecr_repo_url
}

output "ecr_repo_arn" {
  value       = module.ecr.ecr_repo_arn
  description = "The ARN of the ECR repository"
}

output "ecr_repo_name" {
  description = "The name of the ECR repository"
  value = module.ecr.ecr_repo_name
}

