output "ecr_repo_api" {
  value = aws_ecr_repository.chat_stat["api"].name
}

output "ecr_repo_bot" {
  value = aws_ecr_repository.chat_stat["bot"].name
}
