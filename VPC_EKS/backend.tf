terraform {
  backend "s3" {
    bucket = "backend-terraform-state-bucket-for-vpc-and-eks"
    region = "ap-south-1"
    key = "digambar/terraform.tfstate"
  }
}