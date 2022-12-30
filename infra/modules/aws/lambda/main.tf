module "lambda_hello_world" {
 source = "git::https://github.com/Fomiller/tf-module-lambda.git" 
 lambda_name    = var.lambda_name
 lambda_role    = var.lambda_role
 filename         = "${path.module}/lambda_function.zip" 
 handler          = "lambda-go"
 source_code_hash = data.archive_file.zip.output_base64sha256
 runtime          = "go1.x"
 memory_size      = 128
 timeout          = 10
}

