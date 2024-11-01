variable "region" {
  description = "AWS Region where EKS is deployed"
  type        = string
  default     = "eu-north-1"
}

variable "eks_name" {
  description = "EKS cluster name in AWS"
  type        = string
}

variable "oidc_provider" {
  description = "URL of the cluster's OIDC provider"
  type        = string
}

variable "clusterIssuer_email" {
  description = "E-mail to use with ClusterIssuer from cert-manager for ACME"
  type        = string
}