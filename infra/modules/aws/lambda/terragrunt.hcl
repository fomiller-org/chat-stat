include "root" {
  path = find_in_parent_folders()
}

dependencies {
    paths = [
        "../kms",
        "../secrets",
        "../ecr",
    ]
}

dependency "dynamodb" {
    config_path = "../dynamodb"
    mock_outputs = {
         dynamodb_table_stream_arn_chat_stat = "arn:aws:dynamodb:us-east-1:123456789012:table/MOCK-table/stream/2022-01-01T00:00:00.000"
    }
}

dependency "roles" {
    config_path = "../iam/roles"
    mock_outputs = {
        iam_role_arn_lambda_event_sub = "arn:aws:iam::123456789012:role/MOCK-FomillerLambdaEventSub"
    }
}

inputs = {
    dynamodb_table_stream_arn_chat_stat = dependency.dynamodb.outputs.dynamodb_table_stream_arn_chat_stat
    iam_role_arn_lambda_event_sub = dependency.roles.outputs.iam_role_arn_lambda_event_sub
}
