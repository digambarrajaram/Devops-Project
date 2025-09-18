variable "instance_type" {
  type        = string                     # The type of the variable, in this case a string
  default     = "t2.micro"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr_block" {
  type        = list(string)
  default     = ["10.0.1.0/24","10.0.2.0/24"]
  description = "The CIDR block for the public subnet"
}

variable "private_subnet_cidr_block" {
  type        = list(string)
  default     = ["10.0.5.0/24","10.0.6.0/24"]
  description = "The CIDR block for the private subnet"
}
variable "availability_zone" {
  type        = list(string)
  default     = ["ap-south-1a","ap-south-1b"]
  description = "The availability zone for the subnet"
}

variable "route" {
  type        = string
  default     = "0.0.0.0/0"
  description = "The route for the subnet"
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}
