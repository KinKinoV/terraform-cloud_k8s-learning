# Managing Kubernetes in AWS and Azure using Terraform

This project is demonstartion of my journey in learning how to manage EKS and AKS clusters and Kubernetes on AWS/Azure using Terraform.

Table of Contents:
1. [How to Deploy](#how-to-deploy)
    1. [AWS](#aws)
    2. [Azure](#azure)
2. [How to Destroy](#how-to-destroy)
    1. [AWS](#aws-1)
    2. [Azure](#azure-1)

## How to Deploy

### AWS
1. Deploy EKS cluster using [/aws/eks/](/aws/eks/) Terraform files
2. After deploying EKS, use next command:
```bash
# This command adds k8s credentials to your local .kubeconfig
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
3. Deploy all kubernetes resources using [/aws/cluster-managment/](/aws/cluster-managment/) Terraform files. After aplying them:
    1. Uncomment [`kubernetes_manifest.cluster-issuer`](/aws/cluster-managment/cert-manager_helm.tf#L47)
    2. Uncomment [`kubernetes_ingress_v1.google_echoserver`](/aws/cluster-managment/deployments.tf#L49)
    3. Apply everything once again

### Azure

## How to Destroy

### AWS
To Destroy infrastructure:
1. Destroy `cluster-managment` resources in reverse order(comment resources mentioned and apply changes before destroying everything else).
2. Destroy managed EKS cluster resources in `eks` folder.

### Azure