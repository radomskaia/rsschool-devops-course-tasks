# Kubernetes Cluster on AWS

## Overview

This project deploys a 2-node Kubernetes cluster using K3s on AWS infrastructure. The deployment includes a VPC with public and private subnets, a bastion host for secure access, and necessary networking components.

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI configured
- Terraform >= 1.0.0
- SSH key pair for instance access

## Infrastructure Components

The deployed infrastructure includes:

- VPC with DNS support enabled
- 2 public subnets across different availability zones
- 2 private subnets across different availability zones
- Internet Gateway for public internet access
- NAT Gateway or NAT Instance for private subnet internet access
- Bastion hosts in a public subnet for secure SSH access
- K3s Kubernetes cluster with 1 master node and 1 worker node
- Security groups for controlled network access

## Cluster Setup

### Terraform Configuration

Key variables that can be configured:

| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_name` | Name of the VPC | main-vpc |
| `vpc_cidr` | CIDR block for the VPC | 10.0.0.0/16 |
| `public_subnet_cidrs` | CIDR blocks for public subnets | ["10.0.1.0/24", "10.0.2.0/24"] |
| `private_subnet_cidrs` | CIDR blocks for private subnets | ["10.0.10.0/24", "10.0.11.0/24"] |
| `nat_gateway_enabled` | Toggle between NAT Gateway (true) or NAT Instance (false) | true |
| `bastion_key_name` | SSH key name for bastion access | bastion-key |
| `k3s_version` | Version of K3s to install | v1.26.5+k3s1 |
| `k3s_token` | Shared secret for node registration | my-secure-token |

### Deployment Steps

1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```

2. Plan and apply the infrastructure:
   ```bash
   terraform plan
   terraform apply
   ```

3. After deployment, Terraform will output connection information.

## Cluster Access

### Access from Bastion Host

1. SSH to the bastion host:
   ```bash
   ssh -i /path/to/key.pem ec2-user@<bastion-public-ip>
   ```

2. Run the setup script to configure kubectl:
   ```bash
   ./setup_kubectl.sh <k3s-master-private-ip>
   ```

3. Verify the cluster is running:
   ```bash
   kubectl get nodes
   ```

## NAT Options

This project offers two NAT implementation options:

- **NAT Gateway (AWS managed)**: Simpler to manage, more reliable, but more expensive. Enabled when `nat_gateway_enabled = true`.
- **NAT Instance (EC2-based)**: More cost-effective but requires more management. Configured with proper rules for IP forwarding. Enabled when `nat_gateway_enabled = false`.

### Access from Local Computer

1. Run the local access setup script:
   ```bash
   ./scripts/setup_local_access.sh /path/to/key.pem
   ```

1. Verify the NGINX pod is running:
   ```bash
   kubectl get pod nginx
   kubectl get all --all-namespaces | grep nginx
   ```

2. To deploy additional workloads:
   ```bash
   kubectl apply -f your-workload.yaml
   ```

## Security Considerations

- All private instances are in private subnets
- SSH access is limited to the bastion host
- Security groups follow the principle of the least privilege
- K3s API server is only accessible through the bastion host

## Troubleshooting

- If you can't connect to the cluster, check that the SSH tunnel is running
- If nodes are not joining, verify security group rules and check the K3s token
- For other issues, check the logs on the respective instances:
  ```bash
  sudo journalctl -u k3s
  sudo journalctl -u k3s-agent
  ```

## CI/CD with GitHub Actions

The project includes GitHub Actions workflows for infrastructure deployment:

- **Terraform Check**: Verifies Terraform formatting
- **Terraform Plan**: Generates an execution plan
- **Terraform Apply**: Applies changes to the infrastructure (only on the main branch)

To use CI/CD:
- Push changes to the main branch to trigger automatic deployment
- Create a pull request to see the plan without applying changes

## Repository Configuration

### Required Repository Secrets

To enable the GitHub Actions workflows, configure the following repository secret:

- `AWS_ROLE`: ARN of the IAM Role to assume via OIDC (e.g., `arn:aws:iam::123456789012:role/github-actions-role`)

Make sure the IAM role has permissions to access the S3 bucket and DynamoDB table used in your backend configuration.
