resource "aws_iam_role" "lambda_twitch_event_sub" {
  name               = "${title(var.namespace)}LambdaTwitchEventSub"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_twitch_event_sub_webhook" {
  name               = "${title(var.namespace)}LambdaTwitchEventSubWebhook"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_twitch_record_manager" {
  name               = "${title(var.namespace)}LambdaTwitchRecordManager"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "sfn_chat_stat_logger" {
  name               = "${title(var.namespace)}SfnChatStatLogger"
  assume_role_policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
     {
        "Effect":"Allow",
        "Principal": {
           "Service": "states.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
     }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_timestream_query" {
  name               = "${title(var.namespace)}LambdaTimestreamQuery"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
