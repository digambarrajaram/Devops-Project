provider "aws" {
  region = "ap-south-1"
}
data "aws_security_group" "jenkins-sg" {
  id = "sg-0910da73e51bab24a"
}
resource "aws_instance" "instance"  {
  ami = "ami-01b6d88af12965bb6"
  instance_type = "t2.medium"
  key_name = "aws-ec2-key"
  vpc_security_group_ids = [data.aws_security_group.jenkins-sg.id]

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "backend-terraform-state-bucket-for-vpc-and-eks"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "version" {
  bucket = "backend-terraform-state-bucket-for-vpc-and-eks"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "dynamodb_table" {
  name     = "terraform-state-lock-table"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}

output "jenkins_ip" {
  value = aws_instance.instance.public_ip
}

output "id" {
  value = aws_instance.instance.id
}

output "bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}




