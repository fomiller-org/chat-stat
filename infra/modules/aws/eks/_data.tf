data "aws_eks_cluster" "fomiller" {
  name = "${var.namespace}-cluster"
}
