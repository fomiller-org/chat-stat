include "root" {
  path = find_in_parent_folders()
}

dependency "roles" {
    config_path = "../roles"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        iam_role_name_lambda_twitch_event_sub = "FomillerLambdaTwitchEventSub"
        iam_role_name_lambda_twitch_event_sub_webhook = "FomillerLambdaTwitchEventSubWebhook"
        iam_role_name_lambda_twitch_record_manager = "FomillerLambdaTwitchRecordManager"
        iam_role_name_lambda_timestream_query = "FomillerLambdaTimestreamQuery"
        iam_role_name_sfn_chat_stat_logger = "FomillerSfnChatStatLogger"
    }
}

dependency "sfn" {
    config_path = "../../sfn"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        sfn_arn_chat_stat_logger = "arn:aws:states:us-east-1:12346789012:stateMachine:MOCK-fomiller-chat-stat-logger"
    }
}

dependency "s3" {
    config_path = "../../s3"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
         s3_bucket_arn_chat_stat = "arn:aws:s3:::fomiller-dev-chat-stat"
    }
}

inputs = {
    iam_role_name_lambda_twitch_event_sub = dependency.roles.outputs.iam_role_name_lambda_twitch_event_sub
    iam_role_name_lambda_twitch_event_sub_webhook = dependency.roles.outputs.iam_role_name_lambda_twitch_event_sub_webhook
    iam_role_name_lambda_twitch_record_manager = dependency.roles.outputs.iam_role_name_lambda_twitch_record_manager
    iam_role_name_lambda_timestream_query = dependency.roles.outputs.iam_role_name_lambda_timestream_query
    iam_role_name_sfn_chat_stat_logger = dependency.roles.outputs.iam_role_name_sfn_chat_stat_logger
    sfn_arn_chat_stat_logger = dependency.sfn.outputs.sfn_arn_chat_stat_logger
    s3_bucket_arn_chat_stat = dependency.s3.outputs.s3_bucket_arn_chat_stat
}
