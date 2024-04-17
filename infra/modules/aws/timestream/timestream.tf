resource "aws_timestreamwrite_table" "chat_stat" {
  database_name = var.namespace
  table_name    = "chat_stat"

  retention_properties {
    memory_store_retention_period_in_hours  = 336
    magnetic_store_retention_period_in_days = 365
  }
}
