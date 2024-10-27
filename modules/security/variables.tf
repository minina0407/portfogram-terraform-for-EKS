# modules/security/variables.tf
variable "name_prefix" {
  description = "리소스 이름에 사용될 접두사"
  type        = string
}

variable "vpc_id" {
  description = "보안 그룹이 생성될 VPC ID"
  type        = string
}

variable "tags" {
  description = "모든 리소스에 적용될 태그"
  type        = map(string)
  default     = {}
}
variable "eks_cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN"
  type        = string
}
