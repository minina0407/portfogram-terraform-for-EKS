# modules/load_balancer/variables.tf
variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the load balancer will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the load balancer will be placed"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnets are required for high availability."
  }
}

variable "target_port" {
  description = "Port number for the target group"
  type        = number

  validation {
    condition     = var.target_port > 0 && var.target_port <= 65535
    error_message = "Please provide a valid port number between 1 and 65535."
  }
}

variable "listener_port" {
  description = "Port number for the listener"
  type        = number

  validation {
    condition     = var.listener_port > 0 && var.listener_port <= 65535
    error_message = "Please provide a valid port number between 1 and 65535."
  }
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "Health check interval must be between 5 and 300 seconds."
  }
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint URL"
  type        = string
}