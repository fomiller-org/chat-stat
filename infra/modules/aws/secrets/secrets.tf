resource "aws_secretsmanager_secret" "terraform_creds" {
  name       = "fomiller-terraform-${var.environment}-creds"
  kms_key_id = var.chat_stat_master_kms_key_arn
}

resource "aws_secretsmanager_secret_version" "terraform_creds" {
  secret_id = aws_secretsmanager_secret.terraform_creds.id
  secret_string = jsonencode(tomap({
    "access_key_id"     = var.terraform_user,
    "secret_access_key" = var.terraform_pass
    }
  ))
}
