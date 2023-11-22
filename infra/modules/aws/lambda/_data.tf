data "archive_file" "zip" {
  type        = "zip"
  source_file = "${path.module}/bin/lambda_hello.exe"
  output_path = "${path.module}/lambda_function.zip"
}
