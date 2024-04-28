locals {
  source_code_hash = {
    timestream_query         = fileexists("${path.module}/bin/timestream-query/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-event-sub/bootstrap.zip") : data.aws_lambda_function.timestream_query_exists[0].source_code_hash
    twitch_event_sub         = fileexists("${path.module}/bin/twitch-event-sub/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-event-sub/bootstrap.zip") : data.aws_lambda_function.twitch_event_sub_exists[0].source_code_hash
    twitch_event_sub_webhook = fileexists("${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-event-sub-webhook/bootstrap.zip") : data.aws_lambda_function.twitch_event_sub_webhook_exists[0].source_code_hash
    twitch_record_manager    = fileexists("${path.module}/bin/twitch-record-manager/bootstrap.zip") ? filebase64sha256("${path.module}/bin/twitch-record-manager/bootstrap.zip") : data.aws_lambda_function.twitch_record_manager_exists[0].source_code_hash
  }
}
