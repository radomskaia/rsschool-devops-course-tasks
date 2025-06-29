variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources in"
  default     = "ap-southeast-1"
}


variable "vpc_name" {
  type        = string
  description = "Name for VPC"
  default     = "main-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR for public subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR for private subnet"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "bastion_instance_type" {
  type        = string
  description = "Instance type for bastion host"
  default     = "t2.micro"
}

variable "bastion_key_name" {
  type        = string
  description = "SSH key name for bastion host"
  default     = "bastion-key"
}

variable "nat_gateway_enabled" {
  type        = bool
  description = "Enable NAT Gateway (true) or use NAT Instance (false)"
  default     = false
}

variable "nat_instance_type" {
  type        = string
  description = "Instance Type for NAT Instance"
  default     = "t2.micro"
}


variable "k3s_version" {
  type        = string
  description = "k3s version to install"
  default     = "v1.26.5+k3s1"
}

variable "k3s_instance_type" {
  type        = string
  description = "Instance type for k3s nodes"
  default     = "t2.micro"
}

variable "k3s_token" {
  type        = string
  description = "Token for connecting nodes to the k3s cluster"
  default     = "my-secure-token"
}

variable "worker_count" {
  type        = number
  description = "Number of worker nodes k3s"
  default     = 1
}
