include "root" {
  path = find_in_parent_folders()
}

dependency "roles" {
    config_path = "../roles"
    mock_outputs = {
        iam_role_name_lambda_event_sub = "FomillerLambdaEventSub"
    }
}

inputs = {
    iam_role_name_lambda_event_sub = dependency.roles.outputs.iam_role_name_lambda_event_sub
}
