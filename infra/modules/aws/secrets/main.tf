resource "aws_secretsmanager_secret" "terraform_creds" {
  name       = "fomiller-terraform-dev-creds"
  kms_key_id = data.aws_kms_key.chat_stat_master.arn
}

resource "aws_secretsmanager_secret_version" "terraform_creds" {
  secret_id = aws_secretsmanager_secret.terraform_creds.id
  secret_string = jsonencode(tomap({
    "user" = var.terraform_user,
    "pass" = var.terraform_pass
    }
  ))
}
