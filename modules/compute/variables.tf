variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "ARN of the IAM role for EKS nodes"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "ID of the security group for EKS cluster"
  type        = string
}

variable "node_groups" {
  description = "Configuration for EKS node groups"
  type = map(object({
    desired_size  = number
    max_size      = number
    min_size      = number
    disk_size     = number
    instance_type = string
  }))
}

variable "tags" {
  description = "Map of tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Please provide a valid CIDR block format."
  }
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets_cidr) > 0
    error_message = "At least one public subnet CIDR block is required."
  }
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) > 0
    error_message = "At least one private subnet CIDR block is required."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for high availability."
  }
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}