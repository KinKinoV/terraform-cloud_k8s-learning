# Managing EKS and Kubernetes using Terraform

This project is demonstartion of my journey in learning how to manage EKS cluster and Kubernetes on AWS using Terraform.

## How to deploy

1. Deploy EKS cluster using [/terraform/eks/](/terraform/eks/) Terraform files
2. After deploying EKS, use next command:
```bash
# This command adds k8s credentials to your local .kubeconfig
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
3. Deploy all kubernetes resources using [/terraform/cluster-managment/](/terraform/cluster-managment/) Terraform files. After aplying them:
    1. Uncomment [`kubernetes_manifest.cluster-issuer`](/terraform/cluster-managment/cert-manager_helm.tf#L47)
    2. Uncomment [`kubernetes_ingress_v1.google_echoserver`](/terraform/cluster-managment/deployments.tf#L49)
    3. Apply everything once again

## How to destroy

To Destroy infrastructure:
1. Destroy `cluster-managment` resources in reverse order(comment resources mentioned and apply changes before destroying everything else).
2. Destroy managed EKS cluster resources in `eks` folder.