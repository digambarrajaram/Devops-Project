resource "aws_ecr_repository" "my_app_repo" {
  name                 = "application_docker_repo"
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  # Optional: Add tags
  tags = {
    Environment = "Development"
    Project     = "Python_App"
  }
}

