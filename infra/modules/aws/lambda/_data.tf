data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/bin/hello/bootstrap"
  output_path = "${path.module}/bin/hello/lambda_function.zip"
}

data "aws_lambda_function" "twitch_event_sub_exists" {
  count         = fileexists("${path.module}/bin/twitch-event-sub/bootstrap.zip") ? 0 : 1
  function_name = "${var.namespace}-${var.app_prefix}-twitch-event-sub"
}

data "aws_lambda_function" "twitch_event_sub_webhook_exists" {
  count         = fileexists("${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip") ? 0 : 1
  function_name = "${var.namespace}-${var.app_prefix}-twitch-event-sub-webhook"
}

data "aws_lambda_function" "twitch_record_manager_exists" {
  count         = fileexists("${path.module}/bin/twitch-record-manager/bootstrap.zip") ? 0 : 1
  function_name = "${var.namespace}-${var.app_prefix}-twitch-record-manager"
}

# data "archive_file" "twitch_event_sub" {
#   type        = "zip"
#   source_file = "${path.module}/bin/twitch-event-sub/bootstrap"
#   output_path = "${path.module}/bin/twitch-event-sub/lambda_function.zip"
# }
#
# data "archive_file" "twitch_event_sub_webhook" {
#   type        = "zip"
#   source_file = "${path.module}/bin/twitch-event-sub-webhook/bootstrap"
#   output_path = "${path.module}/bin/twitch-event-sub-webhook/lambda_function.zip"
# }
#
# data "archive_file" "twitch_record_manager" {
#   type        = "zip"
#   source_file = "${path.module}/bin/twitch-record-manager/bootstrap"
#   output_path = "${path.module}/bin/twitch-record-manager/lambda_function.zip"
# }
