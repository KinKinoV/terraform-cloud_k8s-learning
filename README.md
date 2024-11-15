# Managing Kubernetes in AWS and Azure using Terraform

This project is demonstartion of my journey in learning how to manage EKS and AKS clusters and Kubernetes on AWS/Azure using Terraform.

Table of Contents:
1. [How to Deploy](#how-to-deploy)
    1. [AWS](#aws)
    2. [Azure](#azure)
2. [How to Destroy](#how-to-destroy)
    1. [AWS](#aws-1)
    2. [Azure](#azure-1)
3. [Usefull Links](#usefull-links)

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
1. Deploy AKS cluster using [/azure/aks/](/azure/aks/) Terraform files
2. After deployment finishes use this command:
```bash
# This command outputs "kube_config" output values into the temp aks_config file
echo "$(terraform output kube_config)" > ./aks_config
```
3. Check file for ASCII EOT characters, if they are present - remove them
4. Copy or move contents of the `aks_config` file to your default kubeconfig file (`~/.kube/config`) or set `KUBECONFIG` env variable with path to `aks_config` file. Now you should be able to check AKS deployment using `kubectl get nodes` or other similar commands.
5. Take values of outputs `kubernetes_cluster_name`, `dns_zone_name`, `resource_group_name` and use them as `aks_name`, `dns_zone_name` and `rg_name` in `values.tfvars` at [azure/kubernetes/](/azure/kubernetes/) directory.
6. Fill out other required variables and then deploy infrastructure in [azure/kubernetes/](/azure/kubernetes/) directory.
    - After deploying for the first time, go uncomment [ClusterIssuer](/azure/kubernetes/cert-manager.tf#L54) in `/azure/kubernetes/cert-manager.tf` and manifests at [`/azure/kubernetes/test-deployment.tf`](/azure/kubernetes/test-deployment.tf) and deploy once again
7. Now you should be able to access Istio's demo-app Bookinfo deployment at `bookinfo.<dns_zone_name>` over HTTPS.

## How to Destroy

### AWS
To Destroy infrastructure:
1. Destroy `cluster-managment` resources in reverse order(comment resources mentioned and apply changes before destroying everything else).
2. Destroy managed EKS cluster resources in `eks` folder.
3. Delete contents of the `~/.kube/config` file

### Azure

To Destroy infrastructure:
1. Destroy `kubernetes` resources in corresponding folder in reverse order.
2. Destroy `aks` resources in corresponding folder.
3. Delete contents of the `~/.kube/config` file or delete custom config file from your machine (should be at `/path/to/project/terraform-cloud_k8s-learning/azure/aks/aks_config`).


# Usefull Links

1. [Workload Identity in AKS with Terraform](https://surajblog.medium.com/workload-identity-in-aks-with-terraform-9d6866b2bfa2)
2. [Setting up ExternalDNS for Services on Azure](https://kubernetes-sigs.github.io/external-dns/v0.14.2/tutorials/azure/#assign-a-role-to-the-managed-identity)
