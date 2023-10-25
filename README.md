# k3s multi-node cluster setup with DB as external node

## Overview:
This repo contains the terraform configuration to setup k3s cluster with below nodes:
- k3s master nodes (No. of nodes(s): 2)
- k3s worker nodes (No. of nodes(s): 2)
- k3s ETCD as external DB node (No. of nodes(s): 1)
- k3s HAproxy load balancer node (No. of nodes(s): 1)
- k3s Bastion node (No. of nodes(s): 1)

## Pre-requisites:
This setup assumes the following pre-requisites:
- AWS account (with Access key ID & Secret access key)
- `terraform` utility to be installed from the machine where this is being configured

## How it is being configured:
This setup configures the cluster in a following manner:
- Creates a dedicated VPC
- Creates a public & private subnet in that VPC
- Creates IGW, NAT GW, route tables
- Configure route table associations
- Deploy the bastion host in public subnet
- Deploy k3s nodes in private subnet (so they all can only be accesses from bastion host)
- Setup the entire cluster
- Copy the kubeconfig file from master node to bastion host (so the cluster can be accessed directly from bastion host and there should not be any need of accessing any of the nodes directly)

## Steps to deploy & setup:
- Configure AWS credentials using following command:
```
aws configure
```
- Clone the repository to the local machine:
```
git clone git@github.com:nazim-deriv/k3s-multi-node-with-external-db.git
cd k3s-multi-node-with-external-db/
```
- Generate SSH key pair inside the present directory (This is essential to configure the k3s cluster since it is needed to access nodes & also to perform `remote-exec` on bastion)
```
ssh-keygen -t rsa -b 4096
```
- Update the public key inside `misc.tf` file under `public_key` value
- Also, please make sure private key is named as `id_rsa` and is present inside the present module directory (This is essential since this key will be used to SSH to nodes to perform configuration)
- Initialize the TF
```
terraform init
```
- Format & validate the TF configuration files
```
terraform fmt
terraform validate
```
- Perform the TF plan to confirm no issues
```
terraform plan
```
- If the plan looks good, run the following command to setup & configure the cluster
```
terraform apply --auto-approve
```

## Verify the deployment
You can perform following to verify if the cluster is being setup and working as expected post successful TF execution
- Add the `id_rsa` key to your SSH key identification
```
ssh-add id_rsa
```
- Login to bastion host using its public IP (The IP should be available in the output)
```
ssh -A admin@<public_ip>
```
- Bastion host should already have `kubectl` installed and cluster's `kubeconfig` file should also be available for you inside `/home/admin/.kube/config` directory
- You can then execute any `kubectl` commands to interact with the cluster
```
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```
- Go ahead and try deploying the test nginx deployment on the cluster
```
kubectl create deploy nginx --image=nginx --replicas=6
kubectl get pods -o wide
```
> Note: Since all of the k3s cluster nodes (except bastion) are deployed inside private subnet, they can only be accessed from bastion host. The necessary security group rule to allow the SSH from bastion to all nodes has already been added

## Destroy the setup:
> **Warning**
> This is a destructive command. So before its execution, please make sure you are destroying only required resources and it is not impacting any other resources. You may use following command to perform a dry run to see the resources being deleted are the ones which are intended to be.
>```
>terraform destroy
>```
- Destroying the setup is as simple as creating it. Execute following command to destroy the setup:
```
terraform destroy --auto-approve
```

## Troubleshoot
- In the event the installation fails, please make sure the private key configured has appropriate permissions, located inside present module directory and is named as `id_rsa`
- Also, please make sure the public key used in `misc.tf` file is exactly the one associated with the private key
- In case if there are any issues with the cluster, you can SSH to any of the k3s nodes from bastion host and check the respective services status as well as logs (cloud-init-output.log or service logs)

## What next?
At last, this setup is not perfect and there is a lot of room for further improvements. Listing out few of them as follows:
- Cluster scalability
- ~~Appropriate Modules hierarchy & simplification~~
- SSL implementation (cluster wide)
- DB High availability implementation
- Cluster external traffik
- Replace ETCD with more robust DB (PostgreSQL for e.g.!)
- Replace HAproxy with any other load balancer (Nginx for e.g.!)

Please feel free to add more if you can think of any !

Test Commit
