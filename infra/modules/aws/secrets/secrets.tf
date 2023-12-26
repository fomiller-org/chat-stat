resource "aws_secretsmanager_secret" "twitch_creds" {
  name       = "${var.environment}/${var.namespace}/twitch-client-secret"
  kms_key_id = var.kms_key_arn_master
}

resource "aws_secretsmanager_secret_version" "twitch_creds" {
  secret_id = aws_secretsmanager_secret.twitch_creds.id
  secret_string = jsonencode(tomap({
    "client_id"     = var.twitch_client_id
    "client_secret" = var.twitch_client_secret
    }
  ))
}
