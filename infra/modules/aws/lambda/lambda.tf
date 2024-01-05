resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.namespace}-${var.app_prefix}-${var.lambda_name}"
  role             = data.aws_iam_role.hello_world.arn
  handler          = "bootstrap"
  filename         = "${path.module}/bin/hello/lambda_function.zip"
  source_code_hash = data.archive_file.hello_world.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
}

data "aws_iam_role" "hello_world" {
  name = var.lambda_role
}


resource "aws_lambda_function" "twitch_event_sub" {
  function_name    = "${var.namespace}-${var.app_prefix}-twitch-event-sub"
  role             = var.iam_role_arn_lambda_twitch_event_sub
  handler          = "bootstrap"
  filename         = "${path.module}/bin/twitch-event-sub/lambda_function.zip"
  source_code_hash = data.archive_file.twitch_event_sub.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      TWITCH_CLIENT_ID     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
      TWITCH_CLIENT_SECRET = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
    }
  }
}

resource "aws_lambda_function" "twitch_event_sub_webhook" {
  function_name    = "${var.namespace}-${var.app_prefix}-twitch-event-sub-webhook"
  role             = var.iam_role_arn_lambda_twitch_event_sub_webhook
  handler          = "bootstrap"
  filename         = "${path.module}/bin/twitch-event-sub-webhook/lambda_function.zip"
  source_code_hash = data.archive_file.twitch_event_sub_webhook.output_base64sha256
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      TWITCH_CLIENT_ID     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
      TWITCH_CLIENT_SECRET = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
    }
  }
}
