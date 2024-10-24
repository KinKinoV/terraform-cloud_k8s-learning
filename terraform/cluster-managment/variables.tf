variable "region" {
  description = "AWS Region where EKS is deployed"
  type        = string
  default     = "eu-north-1"
}

variable "eks_name" {
  description = "EKS cluster name in AWS"
  type        = string
}