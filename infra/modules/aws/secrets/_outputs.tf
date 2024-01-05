output "secretsmanager_secret_version_twitch_creds" {
  value     = aws_secretsmanager_secret_version.twitch_creds.secret_string
  sensitive = true
}
