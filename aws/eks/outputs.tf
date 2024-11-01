output "azs" {
  value = data.aws_availability_zones.available.names
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_provider" {
  description = "URL of the cluster's OIDC provider"
  value       = module.eks.oidc_provider
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks.cluster_name
}

output "hosted_zone_nameservers" {
  description = "List of Name Servers used in Hosted Zone"
  value       = module.eks_hosted-zone.route53_zone_name_servers
}