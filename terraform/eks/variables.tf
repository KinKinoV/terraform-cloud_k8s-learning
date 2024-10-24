variable "region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "eu-north-1"
}

variable "cidr" {
  description = "VPC CIDR for the project"
  type        = string
  default     = "10.0.0.0/16"
}