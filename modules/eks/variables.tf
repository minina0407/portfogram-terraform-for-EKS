variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for the EKS cluster and nodes"
}

variable "node_groups" {
  description = "List of node group configurations"
  type        = map(object({
    name          = string
    instance_type = string
    disk_size     = number
    desired_size  = number
    min_size      = number
    max_size      = number
  }))
}
