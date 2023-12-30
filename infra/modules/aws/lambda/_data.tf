data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/bin/hello/bootstrap"
  output_path = "${path.module}/lambda_function.zip"
}

data "archive_file" "event_sub" {
  type        = "zip"
  source_file = "${path.module}/bin/twitch/eventSub/bootstrap"
  output_path = "${path.module}/lambda_function.zip"
}
