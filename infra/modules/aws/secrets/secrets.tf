resource "aws_secretsmanager_secret" "deployer_creds" {
  name       = "fomiller-${var.environment}-terraform-deployer-creds"
  kms_key_id = var.chat_stat_master_kms_key_arn
}

resource "aws_secretsmanager_secret_version" "deployer_creds" {
  secret_id = aws_secretsmanager_secret.deployer_creds.id
  secret_string = jsonencode(tomap({
    "access_key_id"     = var.terrafrom_deployer_user,
    "secret_access_key" = var.terraform_deployer_pass
    }
  ))
}
