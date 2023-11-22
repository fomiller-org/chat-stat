resource "aws_elasticache_cluster" "redis" {
  cluster_id        = "${var.app_prefix}-redis"
  engine            = "redis"
  engine_version    = "7.0"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  port              = 6379
  apply_immediately = true

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }

}
