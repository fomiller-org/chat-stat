data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/bin/hello/bootstrap"
  output_path = "${path.module}/bin/hello/lambda_function.zip"
}

data "archive_file" "twitch_event_sub" {
  type        = "zip"
  source_file = "${path.module}/bin/twitch-event-sub/bootstrap"
  output_path = "${path.module}/bin/twitch-event-sub/lambda_function.zip"
}

data "archive_file" "twitch_event_sub_webhook" {
  type        = "zip"
  source_file = "${path.module}/bin/twitch-event-sub-webhook/bootstrap"
  output_path = "${path.module}/bin/twitch-event-sub-webhook/lambda_function.zip"
}
