module "lambda_hello_world" {
 source = "git::https://github.com/Fomiller/tf-module-lambda.git" 
 lambda_name      = "${var.app_prefix}-${var.lambda_name}"
 lambda_role      = data.aws_iam_role.hello_world.arn
 filename         = "${path.module}/lambda_function.zip" 
 handler          = "lambda_hello.exe"
 source_code_hash = data.archive_file.zip.output_base64sha256
 runtime          = "go1.x"
 memory_size      = 128
 timeout          = 10
}

data "aws_iam_role" "hello_world" {
    name = var.lambda_role
}
