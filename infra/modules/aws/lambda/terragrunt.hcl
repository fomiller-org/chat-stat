include "root" {
  path = find_in_parent_folders()
}

dependencies {
    paths = [
        "../kms",
        "../ecr",
    ]
}

dependency "secrets" {
    config_path = "../secrets"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
         secretsmanager_secret_version_twitch_creds = {"client_id":"mock-${uuid()}","client_secret":"mock-${uuid()}"}
    }
}

dependency "dynamodb" {
    config_path = "../dynamodb"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
         dynamodb_table_stream_arn_chat_stat = "arn:aws:dynamodb:us-east-1:123456789012:table/MOCK-table/stream/2022-01-01T00:00:00.000"
    }
}

dependency "roles" {
    config_path = "../iam/roles"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        iam_role_arn_lambda_twitch_event_sub = "arn:aws:iam::123456789012:role/MOCK-FomillerLambdaTwitchEventSub"
        iam_role_arn_lambda_twitch_event_sub_webhook = "arn:aws:iam::123456789012:role/MOCK-FomillerLambdaTwitchEventSubWebhook"
    }
}

inputs = {
    dynamodb_table_stream_arn_chat_stat = dependency.dynamodb.outputs.dynamodb_table_stream_arn_chat_stat
    iam_role_arn_lambda_twitch_event_sub = dependency.roles.outputs.iam_role_arn_lambda_twitch_event_sub
    iam_role_arn_lambda_twitch_event_sub_webhook = dependency.roles.outputs.iam_role_arn_lambda_twitch_event_sub_webhook
    secretsmanager_secret_version_twitch_creds = dependency.secrets.outputs.secretsmanager_secret_version_twitch_creds
}
