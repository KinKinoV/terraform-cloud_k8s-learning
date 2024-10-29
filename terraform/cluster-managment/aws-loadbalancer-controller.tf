# Required policies and roles for the AWS Load Balancer Controller
resource "aws_iam_policy" "aws-lb-controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM role for AWS Load Balancer Controller in EKS cluster"

  policy = file("${path.module}/aws-lb-controller_iam-policy.json")
}

module "irsa-aws-lb-controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSLoadBalancerControllerRole"
  provider_url                  = var.oidc_provider
  role_policy_arns              = [aws_iam_policy.aws-lb-controller.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
}

# Helm release of the needed controller

resource "helm_release" "aws-lb-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [<<EOT
serviceAccount:
  create: true
  name: aws-load-balancer-controller
  annotations:
    eks.amazonaws.com/role-arn: ${module.irsa-aws-lb-controller.iam_role_arn}
clusterName: ${var.eks_name}
  EOT
  ]
}