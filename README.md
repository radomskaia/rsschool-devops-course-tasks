# Infrastructure Documentation

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Authentication with AWS](#authentication-with-aws)
- [Terraform Configuration](#terraform-configuration)
  - [Backend Setup](#backend-setup)
  - [Core Variables](#core-variables)
  - [Core Commands](#core-commands)
- [NAT Options](#nat-options)
- [Bastion Host](#bastion-host)
- [Security Considerations](#security-considerations)
- [Outputs](#outputs)
- [Deployment Process](#deployment-process)
  - [Local Development](#local-development)
  - [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [GitHub Repository Setup](#repository-configuration)

## Overview

This project uses [Terraform](https://www.terraform.io/downloads.html) to automate the deployment and management of infrastructure. All infrastructure configuration is located in the `/terraform` directory.

The infrastructure includes:

- VPC with DNS support enabled
- 2 public subnets across different availability zones
- 2 private subnets across different availability zones
- Internet Gateway for public internet access
- Bastion host in a public subnet for secure SSH access to private resources
- Choice between NAT Gateway (simpler but more expensive) or NAT Instance (cheaper but requires more management)
- Security groups for controlled access


## Prerequisites

- Terraform CLI >= 1.6.6
- AWS account with:
  - S3 bucket for state storage
  - DynamoDB table for state locking
  - IAM Role configured with trust policy for GitHub OIDC

## Authentication with AWS

This project uses IAM OIDC (OpenID Connect) for authentication with AWS. This approach allows GitHub Actions to obtain temporary AWS credentials using short-lived tokens via OIDC, eliminating the need for long-lived AWS access keys in repository secrets.

Learn more: [GitHub Actions OIDC with AWS](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## Terraform Configuration

### Backend Setup

The project uses remote state storage for Terraform, configured in the `backend.tf` file. This ensures secure state storage and enables collaborative work.

### Core Variables
| Variable | Description | Default |
|----------|-------------|---------|
| `vpc_name` | Name of the VPC | main-vpc |
| `vpc_cidr` | CIDR block for the VPC | 10.0.0.0/16 |
| `public_subnet_cidrs` | CIDR blocks for public subnets | ["10.0.1.0/24", "10.0.2.0/24"] |
| `private_subnet_cidrs` | CIDR blocks for private subnets | ["10.0.10.0/24", "10.0.11.0/24"] |
| `nat_gateway_enabled` | Toggle between NAT Gateway (true) or NAT Instance (false) | true |
| `bastion_key_name` | SSH key name for bastion access | bastion-key |



### Core Commands
1. **Initialize Terraform:**

   ```bash
   cd terraform
   terraform init
   ```

2. **Review planned changes:**

   ```bash
   terraform plan
   ```

3. **Apply changes:**

   ```bash
   terraform apply
   ```

4. **Destroy infrastructure:**

   ```bash
   terraform destroy
   ```

## NAT Options

This project offers two NAT implementation options:

- **NAT Gateway (AWS managed)**: Simpler to manage, more reliable, but more expensive. Enabled when `nat_gateway_enabled = true`.
- **NAT Instance (EC2-based)**: More cost-effective but requires more management. Configured with proper rules for IP forwarding. Enabled when `nat_gateway_enabled = false`.

## Bastion Host

The bastion host serves as a secure entry point for SSH access to instances in private subnets. It's placed in a public subnet with restricted SSH access and serves as a jump server.

## Security Considerations

- All resources are properly tagged
- Security groups follow the principle of least privilege
- SSH access is restricted to the bastion host
- Private subnets have no direct inbound access from the internet

## Outputs

After applying the configuration, you can access the following outputs:
- VPC ID
- Public and private subnet IDs
- Bastion host public IP (for SSH access)

## Deployment Process

### Local Development

For local development, use the Terraform core commands described above to manage infrastructure.

### CI/CD with GitHub Actions

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
