# Infrastructure Documentation

## Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Authentication with AWS](#authentication-with-aws)
- [Terraform Configuration](#terraform-configuration)
  - [Backend Setup](#backend-setup)
  - [Core Commands](#core-commands)
- [Deployment Process](#deployment-process)
  - [Local Development](#local-development)
  - [CI/CD with GitHub Actions](#cicd-with-github-actions)
- [GitHub Repository Setup](#repository-configuration)

## Overview

This project uses [Terraform](https://www.terraform.io/downloads.html) to automate the deployment and management of infrastructure. All infrastructure configuration is located in the `/terraform` directory.

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
