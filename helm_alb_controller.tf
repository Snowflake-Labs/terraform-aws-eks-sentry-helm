resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.3.3"

  namespace  = "kube-system"


  values = [
    templatefile(
      "${path.module}/templates/alb_controller_values.yaml",
      {
        aws_region = "${var.aws_region}",
        eks_cluster_id = "${module.eks.cluster_id}",
        aws_iam_role_lb_controller_arn = "${aws_iam_role.lb_controller_role.arn}",
      }
    )
  ]
}
