resource "aws_kms_key" "chat_stat_master" {
  description             = "chat stat master key"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "chat_stat_master" {
  name          = "alias/${var.namespace}-${var.app_prefix}-master"
  target_key_id = aws_kms_key.chat_stat_master.key_id
}
