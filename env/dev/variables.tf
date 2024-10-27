variable "project_name" {
    description = "The name of the project"
    type        = string

    validation {
        condition     = can(regex("^[a-z0-9-]+$", var.project_name))
        error_message = "The project name must only contain lowercase letters, numbers, and hyphens."
    }
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string

    validation {
        condition     = can(cidrhost(var.vpc_cidr, 0))
        error_message = "Please enter a valid CIDR block format."
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

variable "kubernetes_version" {
    description = "Kubernetes version"
    type        = string
    default     = "1.27"

    validation {
        condition     = can(regex("^1\\.(2[567]|28)$", var.kubernetes_version))
        error_message = "The Kubernetes version must be between 1.25 and 1.28."
    }
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

    validation {
        condition = alltrue([
            for ng in var.node_groups : (
            ng.min_size <= ng.desired_size &&
            ng.desired_size <= ng.max_size &&
            ng.disk_size >= 20
            )
        ])
        error_message = "The node group configuration is invalid. Please check size and disk configurations."
    }
}

variable "target_port" {
    description = "Target port for the load balancer"
    type        = number

    validation {
        condition     = var.target_port > 0 && var.target_port <= 65535
        error_message = "Please enter a valid port number between 1 and 65535."
    }
}

variable "listener_port" {
    description = "Listener port for the load balancer"
    type        = number

    validation {
        condition     = var.listener_port > 0 && var.listener_port <= 65535
        error_message = "Please enter a valid port number between 1 and 65535."
    }
}