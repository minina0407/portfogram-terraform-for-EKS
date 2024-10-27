variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "ARN of the IAM role for EKS nodes"
  type        = string
}
