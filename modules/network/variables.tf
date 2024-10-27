variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
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

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}