variable "eks_cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  type        = string
  default     = ""
}

variable "eks_node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN"
  type        = string
  default     = ""
}
