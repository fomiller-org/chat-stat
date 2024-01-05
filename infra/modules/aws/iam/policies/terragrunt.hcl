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
    }
}

inputs = {
    iam_role_name_lambda_twitch_event_sub = dependency.roles.outputs.iam_role_name_lambda_twitch_event_sub
    iam_role_name_lambda_twitch_event_sub_webhook = dependency.roles.outputs.iam_role_name_lambda_twitch_event_sub_webhook
}
