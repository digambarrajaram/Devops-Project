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
output "jenkins_ip" {
  value = aws_instance.instance.public_ip
}

output "id" {
  value = aws_instance.instance.id
}

