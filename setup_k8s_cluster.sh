#!/bin/bash

# Step 1: Install dependencies (if not already installed)
echo "Installing Terraform, Ansible, and AWS CLI..."

# Install Terraform
if ! command -v terraform &> /dev/null
then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform -y
fi

# Install Ansible
if ! command -v ansible &> /dev/null
then
    sudo apt update && sudo apt install ansible -y
fi

# Install AWS CLI
if ! command -v aws &> /dev/null
then
    sudo apt install awscli -y
fi

# Step 2: Deploy AWS Infrastructure using Terraform
echo "Deploying AWS infrastructure using Terraform..."
terraform init
terraform apply -auto-approve

# Step 3: Run Ansible playbook to install Kubernetes
echo "Running Ansible playbook to install Kubernetes, Flannel, and Helm..."
ansible-playbook -i inventory.ini playbook.yml

# Step 4: Verify Kubernetes Cluster
echo "Verifying Kubernetes cluster..."
MASTER_IP=$(terraform output -raw master_ip)
echo "SSH-ing into master node at ${MASTER_IP}..."
ssh -i your-key.pem ubuntu@"${MASTER_IP}" "kubectl get nodes"

# Step 5: Access Kubernetes Dashboard
echo "Starting kubectl proxy to access the Kubernetes dashboard..."
kubectl proxy &

# Wait a moment for the proxy to start
sleep 5

# Open the Kubernetes Dashboard URL in the browser
echo "Opening Kubernetes dashboard in browser..."
xdg-open "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"

echo "All steps completed! 🎉"
