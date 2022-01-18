resource "helm_release" "external_dns" {
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  version    = "6.1.1"

  namespace  = "kube-system"

  values = [
    templatefile(
      "${path.module}/templates/external_dns_values.yaml",
      {
        aws_region = "${var.aws_region}",
        aws_zone_type = "${var.external_dns_zone_type}",
        external_dns_eks_service_account = "${kubernetes_service_account.external_dns_service_account.metadata[0].name}",
        aws_iam_role_external_dns = "${aws_iam_role.external_dns_role.name}",
        aws_iam_role_external_dns_arn = "${aws_iam_role.external_dns_role.arn}",
      }
    )
  ]
}
