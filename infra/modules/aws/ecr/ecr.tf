resource "aws_ecr_repository" "chat_stat" {
  for_each             = toset(local.ecr_repos)
  name                 = "${var.app_prefix}-${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
