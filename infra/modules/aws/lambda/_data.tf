data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/bin/hello/bootstrap"
  output_path = "${path.module}/lambda_function.zip"
}
