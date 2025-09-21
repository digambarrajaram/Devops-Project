output "ecr_repo_url" {
    value = aws_ecr_repository.my_app_repo.repository_url
}

output "ecr_repo_arn" {
    value = aws_ecr_repository.my_app_repo.arn
}
output "ecr_repo_name" {
    value = aws_ecr_repository.my_app_repo.name
}