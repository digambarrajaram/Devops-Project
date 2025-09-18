variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "eks_cluster_role_arn" {
  type        = string
  default     = ""
  description = "The ARN of the IAM role for the EKS cluster"
}
variable "eks_cluster_role_name" {
  type        = string
  default     = ""
  description = "The name of the IAM role for the EKS cluster"
}


variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The IDs of the subnets"
}
