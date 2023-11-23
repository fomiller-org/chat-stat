resource "aws_cloudwatch_event_rule" "cs_api_ecr_rule" {
  name        = "${var.namespace}-${var.app_prefix}-ecr-api"
  description = "Rule for SUCCESSFUL Push to chat stat api repo"

  event_pattern = <<EOF
{
  "source": ["aws.ecr"],
  "detail-type": ["ECR Image Action"],
  "detail": {
    "action-type": ["PUSH"],
    "result": ["SUCCESS"],
    "repository-name": ["695434033664.dkr.ecr.us-east-1.amazonaws.com/${var.namespace}-${var.app_prefix}-api"]
  }
}
EOF
}

# resource "aws_cloudwatch_event_rule" "cs_bot_ecr_rule" {
#   name        = "${var.app_prefix}-ecr-api"
#   description = "Rule for SUCCESSFUL Push to chat stat api repo"
#
#   event_pattern = <<EOF
# {
#   "source": ["aws.ecr"],
#   "detail-type": ["ECR Image Action"],
#   "detail": {
#     "action-type": ["PUSH"],
#     "result": ["SUCCESS"],
#     "repository-name": ["695434033664.dkr.ecr.us-east-1.amazonaws.com/${var.namespace}-${var.app_prefix}-bot"]
#   }
# }
# EOF
# }
