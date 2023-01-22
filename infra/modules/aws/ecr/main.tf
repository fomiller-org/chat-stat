locals {
  resource_name = "${var.app_prefix}-api"
}

resource "aws_ecr_repository" "api" {
  name                 = local.resource_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

