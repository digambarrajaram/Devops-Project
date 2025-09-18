
output "eks_cluster_arn" {
  value = aws_eks_cluster.eks_cluster.arn # The actual value to be outputted
  description = "The ARN of the EKS cluster"
}

output "endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "The endpoint of the EKS cluster"
}
