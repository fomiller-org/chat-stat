data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/bin/hello/bootstrap"
  output_path = "${path.module}/bin/hello/lambda_function.zip"
}

data "archive_file" "event_sub" {
  type        = "zip"
  source_file = "${path.module}/bin/event-sub/bootstrap"
  output_path = "${path.module}/bin/event-sub/lambda_function.zip"
}
