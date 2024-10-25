resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name

  values = [
    file("${path.module}/cert-manager_values.yaml")
  ]
}

# Required IAM policy and IRSA for cert-manager to interact with Route53
resource "aws_iam_policy" "cert-manager-issuer-r53" {
  name        = "cert-manager-acme-dns01-route53"
  description = "This policy allows cert-manager to manage ACME DNS01 records in Route53 hosted zones. See https://cert-manager.io/docs/configuration/acme/dns01/route53"

  # Policy contents are taken from https://cert-manager.io/docs/tutorials/getting-started-aws-letsencrypt/#create-an-iam-policy
  policy = file("${path.module}/cert-manager-acme-dns01-route53_iam-policy.json")
}

module "irsa-cert-manager" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "cert-manager-acme-dns01-route53"
  provider_url                  = var.oidc_provider
  role_policy_arns              = [aws_iam_policy.cert-manager-issuer-r53.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${kubernetes_namespace.cert-manager.metadata[0].name}:cert-manager-acme-dns01-route53"]
}

# cert-manager ServiceAccount and permissions in EKS cluster to use with Route53
resource "kubernetes_service_account" "cert-manager-acme-dns01-route53" {
  metadata {
    name      = "cert-manager-acme-dns01-route53"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-cert-manager.iam_role_arn
    }
  }
}

resource "kubernetes_role" "cert-manager-acme-dns01-route53-tokenrequest" {
  metadata {
    name      = "cert-manager-acme-dns01-route53-tokenrequest"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  rule {
    api_groups     = [""]
    resources      = ["serviceaccounts/token"]
    resource_names = ["cert-manager-acme-dns01-route53"]
    verbs          = ["create"]
  }
}

resource "kubernetes_role_binding" "cert-manager-acme-dns01-route53-tokenrequest" {
  metadata {
    name      = "cert-manager-acme-dns01-route53-tokenrequest"
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert-manager-acme-dns01-route53.metadata[0].name
    namespace = kubernetes_namespace.cert-manager.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cert-manager-acme-dns01-route53-tokenrequest.metadata[0].name
  }
}

# Creating ClusterIssuer using manifest
resource "kubernetes_manifest" "cluster-issuer" {
  manifest = yamldecode(<<EOT
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-test
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.clusterIssuer_email}
    privateKeySecretRef:
      name: letsencrypt-test
    solvers:
    - dns01:
        route53:
          region: ${var.region}
          hostedZoneID: "kinkinov.com"
          role: ${module.irsa-cert-manager.iam_role_arn}
          auth:
            kubernetes:
              serviceAccountRef:
                name: ${kubernetes_service_account.cert-manager-acme-dns01-route53.metadata[0].name}
  EOT
  )
}