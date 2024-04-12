resource "aws_lambda_function" "twitch_event_sub" {
  function_name    = "${var.namespace}-${var.app_prefix}-twitch-event-sub"
  role             = var.iam_role_arn_lambda_twitch_event_sub
  handler          = "bootstrap"
  filename         = "${path.module}/bin/twitch-event-sub/bootstrap.zip"
  source_code_hash = local.source_code_hash["twitch_event_sub"]
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      TWITCH_CLIENT_ID     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
      TWITCH_CLIENT_SECRET = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
      REGION               = data.aws_region.current.name
      ACCOUNT              = data.aws_caller_identity.current.account_id
    }
  }
}

resource "aws_lambda_function" "twitch_event_sub_webhook" {
  function_name    = "${var.namespace}-${var.app_prefix}-twitch-event-sub-webhook"
  role             = var.iam_role_arn_lambda_twitch_event_sub_webhook
  handler          = "bootstrap"
  filename         = "${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip"
  source_code_hash = local.source_code_hash["twitch_event_sub_webhook"]
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      TWITCH_CLIENT_ID     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
      TWITCH_CLIENT_SECRET = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
      REGION               = data.aws_region.current.name
      ACCOUNT              = data.aws_caller_identity.current.account_id
    }
  }
}

resource "aws_lambda_function" "twitch_record_manager" {
  function_name    = "${var.namespace}-${var.app_prefix}-twitch-record-manager"
  role             = var.iam_role_arn_lambda_twitch_record_manager
  handler          = "bootstrap"
  filename         = "${path.module}/bin/twitch-record-manager/bootstrap.zip"
  source_code_hash = local.source_code_hash["twitch_record_manager"]
  runtime          = "provided.al2"
  architectures    = ["arm64"]
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      TWITCH_CLIENT_ID     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
      TWITCH_CLIENT_SECRET = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
      REGION               = data.aws_region.current.name
      ACCOUNT              = data.aws_caller_identity.current.account_id
    }
  }
}
