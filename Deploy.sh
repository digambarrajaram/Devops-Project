#!/bin/bash

# Path to your Terraform working directory
TF_DIR="/mnt/d/ansible_learning/Ansible_Terraform/Terraform"

# Navigate to the directory
cd "$TF_DIR" || exit 1

# Check if Terraform is already initialized
if [ -d ".terraform" ]; then
    echo "Terraform already initialized. Skipping 'terraform init'."
else
    echo "Initializing Terraform..."
    terraform init
fi
terraform apply -auto-approve

# 2. Get output and generate Ansible inventory
JENKINS_IP=$(terraform output -raw jenkins_ip)

cp /mnt/c/Users/Digambar\ Rajaram/Downloads/aws-ec2-key.pem ~/.ssh/
chmod 600 ~/.ssh/aws-ec2-key.pem

cat > /mnt/d/ansible_learning/Ansible_Terraform/Ansible/inventory.ini <<EOF
[jenkins]
$JENKINS_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/aws-ec2-key.pem
EOF


# 3. Run Ansible
ansible-playbook -i /mnt/d/ansible_learning/Ansible_Terraform/Ansible/inventory.ini /mnt/d/ansible_learning/Ansible_Terraform/Ansible/Jenkins_config.yaml
