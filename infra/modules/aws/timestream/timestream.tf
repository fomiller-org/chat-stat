resource "aws_timestreamwrite_table" "chat_stat" {
  database_name = var.namespace
  table_name    = "${var.namespace}-${var.app_prefix}"

  retention_properties {
    magnetic_store_retention_period_in_days = 60
    memory_store_retention_period_in_hours  = 24
  }
}
