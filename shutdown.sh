#!/bin/bash

# Destroy Terraform infra for vpc and eks
TF_DIR="/mnt/d/ansible_learning/devops-project/VPC_EKS"
cd "$TF_DIR" || exit 1
terraform destroy

# Destroy Terraform infra for jenkins and backend
TF_DIR="/mnt/d/ansible_learning/devops-project/Terraform"
cd "$TF_DIR" || exit 1
terraform destroy
