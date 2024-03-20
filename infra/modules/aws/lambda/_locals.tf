locals {
  source_code_hash = {
    twitch_event_sub        = fileexists("${path.module}/bin/twitch-event-sub/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-event-sub/bootstrap.zip") : data.aws_lambda_function.exists[0].source_code_hash
    twitch_event_sub_webook = fileexists("${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip") : data.aws_lambda_function.exists[0].source_code_hash
    twitch_record_manager   = fileexists("${path.module}/bin/twitch-record-manager/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-record-manager/bootstrap.zip") : data.aws_lambda_function.exists[0].source_code_hash
  }
}
