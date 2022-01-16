resource "helm_release" "lb_controller" {
  count      = var.enabled ? 1 : 0
  name       = var.helm_chart_name
  chart      = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version    = var.helm_chart_version
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller_role[0].arn
  }

  values = [
    yamlencode(var.settings)
  ]

  depends_on = [kubernetes_namespace.lb_controller]
}
