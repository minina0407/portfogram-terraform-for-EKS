variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_groups" {
  description = "Map of node group configurations"
  type        = map(object({
    name          = string
    instance_type = string
    disk_size     = number
    desired_size  = number
    min_size      = number
    max_size      = number
  }))
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}