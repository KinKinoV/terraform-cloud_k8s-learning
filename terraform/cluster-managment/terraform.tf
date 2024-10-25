terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
  }
}