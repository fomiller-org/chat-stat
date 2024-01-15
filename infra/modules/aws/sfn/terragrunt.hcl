include "root" {
	path = find_in_parent_folders()
}

dependency "secrets" {
    config_path = "../secrets"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
         secretsmanager_secret_version_twitch_creds = {"client_id":"mock-${uuid()}","client_secret":"mock-${uuid()}"}
    }
}

dependency "roles" {
    config_path = "../iam/roles"
    mock_outputs_merge_strategy_with_state = "shallow"
    mock_outputs_allowed_terraform_commands = ["validate", "plan", "apply", "destroy"]
    mock_outputs = {
        iam_role_arn_sfn_chat_stat_logger = "arn:aws:iam::123456789012:role/MOCK-FomillerSfnChatStatLogger"
    }
}

inputs = {
    iam_role_arn_sfn_chat_stat_logger = dependency.roles.outputs.iam_role_arn_sfn_chat_stat_logger
    secretsmanager_secret_version_twitch_creds = dependency.secrets.outputs.secretsmanager_secret_version_twitch_creds
}
