/*terraform {
  backend "s3" {
    bucket = "backend-terraform-state-bucket-for-vpc-and-eks"
    region = "ap-south-1"
    key = "vpc-eks/terraform.tfstate"
    dynamodb_table = "terraform-state-lock-table"
    encrypt = true
  }
}*/

module "vpc" {
  source = "./Modules/VPC"
  eks_cluster_name = var.eks_cluster_name
}

module "eks" {
  source     = "./Modules/EKS"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids  # use private subnets
  depends_on = [ module.vpc ]
  eks_cluster_name = var.eks_cluster_name
}

module "ecr"{
  source = "./Modules/ECR"
}
