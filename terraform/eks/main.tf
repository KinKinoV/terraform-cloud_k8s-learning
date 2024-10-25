provider "aws" {
  region  = var.region
  profile = "default"
}

# Filter out local zones, which are not currently supported 
# with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  cluster_name = "eks-learning-${random_string.suffix.result}"
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = "eks-vpc"
  cidr = var.cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 1)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

data "aws_iam_policy" "vpc_cni_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

module "irsa-vpc-cni" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKS_VPC_CNI_Role-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.vpc_cni_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.26.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
    vpc-cni = {
      service_account_role_arn = module.irsa-vpc-cni.iam_role_arn
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["t3.micro"]
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}

module "eks_hosted-zone" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "4.1.0"

  zones = {
    "${var.zone_name}" = {
      comment = "Hosted zone for application deployed in EKS"
    }
  }
}
