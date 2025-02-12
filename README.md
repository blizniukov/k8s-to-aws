# Kubernetes Cluster on AWS EC2

This setup automates the deployment of a Kubernetes cluster on AWS EC2 using Terraform and Ansible.

## Prerequisites

Before running the setup, ensure you have:

- An AWS account with necessary permissions
- SSH key pair (`your-key.pem`) to access EC2 instances
- Terraform installed (`>= 1.0`)
- Ansible installed (`>= 2.9`)
- AWS CLI installed and configured (`aws configure`)

## Files Overview

- `k8s.tf`: Terraform script to provision AWS resources (EC2 instances, security groups, etc.)
- `setup_k8s_cluster.sh`: Bash script to automate the deployment process
- `playbook.yml`: Ansible playbook to install Kubernetes and set up the cluster

## Deployment Steps

### 1. Clone the Repository

### 2. Run the Setup Script

```sh
chmod +x setup_k8s_cluster.sh
./setup_k8s_cluster.sh
```

This script:

- Installs Terraform, Ansible, and AWS CLI (if missing)
- Deploys AWS infrastructure using Terraform
- Runs the Ansible playbook to configure Kubernetes
- Sets up the Kubernetes dashboard

### 3. Access the Kubernetes Cluster

- **Verify Nodes:**
  ```sh
  ssh -i your-key.pem ubuntu@<master-node-ip>
  kubectl get nodes
  ```
- **Access Kubernetes Dashboard:**
  ```sh
  kubectl proxy &
  xdg-open "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
  ```

### 4. Cleanup (If Needed)

To destroy the infrastructure, run:

```sh
terraform destroy -auto-approve
```

## Notes

- Ensure the AWS key pair (`your-key.pem`) is correctly referenced in the Terraform files.
- Modify the Ansible inventory file (`inventory.ini`) if needed.
- Check security group settings to allow necessary inbound/outbound traffic.

## Troubleshooting

- **Terraform Errors:** Run `terraform validate` and `terraform fmt` to check for syntax errors.
- **Ansible Issues:** Use `ansible-playbook -i inventory.ini playbook.yml --check` to test changes.
- **Kubernetes Not Working:** SSH into the master node and check `kubectl get pods -A` for issues.

Happy clustering! 🚀

