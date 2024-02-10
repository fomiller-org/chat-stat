resource "aws_eks_access_entry" "sfn_logger" {
  cluster_name      = data.aws_eks_cluster.fomiller.name
  principal_arn     = var.iam_role_arn_sfn_chat_stat_logger
  kubernetes_groups = ["admins"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "sfn_logger" {
  cluster_name  = data.aws_eks_cluster.fomiller.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = var.iam_role_arn_sfn_chat_stat_logger

  access_scope {
    type       = "namespace"
    namespaces = ["chat-stat"]
  }
}
