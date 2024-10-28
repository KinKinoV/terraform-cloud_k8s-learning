# Managing EKS and Kubernetes using Terraform

This project is demonstartion of my journey in learning how to manage EKS cluster and Kubernetes on AWS using Terraform.

## How to deploy

1. Deploy EKS cluster using [/terraform/eks/](/terraform/eks/) Terraform files
2. After deploying EKS, use next command:
```bash
# This command adds k8s credentials to your local .kubeconfig
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
3. Deploy all kubernetes resources using [/terraform/cluster-managment/](/terraform/cluster-managment/) Terraform files. After applying all resources, uncomment [`kubernetes_manifest.cluster-issuer`](/terraform/cluster-managment/cert-manager_helm.tf#L47) resource and apply terraform once again.

## How to destroy

To Destroy infrastructure, firstly destroy `cluster-managment` resources, then you can destroy managed EKS cluster resources in `eks` folder.