variable "subnets" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer is deployed"
  type        = string
}
