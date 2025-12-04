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
  description = "ID of the security group for EKS cluster (from security module)"
  type        = string
}

variable "node_security_group_ids" {
  description = "Map of node security group IDs (node group name -> security group ID)"
  type        = map(string)
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

variable "private_subnet_ids" {
  description = "List of private subnet IDs for node groups"
  type        = list(string)
}