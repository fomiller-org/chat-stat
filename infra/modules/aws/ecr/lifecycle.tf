resource "aws_lifecycle_policy" "chat_stat" {
  for_each = [aws_ecr_repository.api.name, aws_ecr_repository.bot.name]
  policy   = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only one latest image, expire all others",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["latest"]
                "countType": "imageCountMoreThan",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 3,
            "description": "Keep only 3 tag images that are not 'latest', expire all others",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
