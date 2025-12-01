variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (used for security group rules)"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster (used for security group tags)"
  type        = string
}

variable "node_groups" {
  description = "Map of node groups (used to create node security groups)"
  type = map(object({
    desired_size  = number
    max_size      = number
    min_size      = number
    disk_size     = number
    instance_type = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster (for dependency resolution)"
  type        = string
  default     = ""
}

variable "eks_node_role_arn" {
  description = "ARN of the IAM role for EKS nodes (for dependency resolution)"
  type        = string
  default     = ""
}
