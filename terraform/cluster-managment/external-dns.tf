resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
}

resource "aws_iam_policy" "external-dns" {
  name        = "AllowExternalDNSUpdates"
  description = "The following IAM Policy document allows ExternalDNS to update Route53 Resource Record Sets and Hosted Zones"

  # Policy definition was taken from https://kubernetes-sigs.github.io/external-dns/v0.14.0/tutorials/aws/#iam-policy
  policy = file("${path.module}/external-dns_iam-policy.json")
}

module "irsa-external-dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "external-dns"
  provider_url                  = var.oidc_provider
  role_policy_arns              = [aws_iam_policy.external-dns.arn]
  oidc_fully_qualified_audiences = [ "sts.awsamazon.com" ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.external-dns.metadata[0].name}:external-dns"]
}

resource "helm_release" "external-dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.15.0"
  namespace  = kubernetes_namespace.external-dns.metadata[0].name

  values = [<<EOT
provider:
  name: aws
env:
  - name: AWS_DEFAULT_REGION
    value: ${var.region}
  EOT
  ]
}