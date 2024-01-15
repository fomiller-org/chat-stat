data "template_file" "chat_stat_logger_sfn" {
  template = file("${path.module}/templates/chat-stat-logger.tpl")
  vars = {
    twitch_client_id     = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_id"]
    twitch_client_secret = jsondecode(var.secretsmanager_secret_version_twitch_creds)["client_secret"]
    cluster_endpoint     = data.aws_eks_cluster.fomiller.endpoint
    cluster_certificate  = data.aws_eks_cluster.fomiller.certificate_authority[0].data
    cluster_name         = "${var.namespace}-cluster"
    namespace            = var.app_prefix
  }
}

resource "aws_sfn_state_machine" "chat_stat_logger" {
  name     = "${var.namespace}-chat-stat-logger"
  role_arn = var.iam_role_arn_sfn_chat_stat_logger

  definition = data.template_file.chat_stat_logger_sfn.rendered
}
