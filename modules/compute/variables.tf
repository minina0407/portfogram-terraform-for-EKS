variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "kubernetes_version" {
  description = "쿠버네티스 버전"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "서브넷 ID 리스트"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  type        = string
}

variable "eks_node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN"
  type        = string
}

variable "eks_cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  type        = string
}

variable "node_groups" {
  description = "노드 그룹 설정"
  type = map(object({
    desired_size  = number
    max_size      = number
    min_size      = number
    disk_size     = number
    instance_type = string
  }))
}

variable "tags" {
  description = "태그 맵"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "유효한 CIDR 블록을 입력하세요."
  }
}

variable "public_subnets_cidr" {
  description = "퍼블릭 서브넷 CIDR 블록 리스트"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets_cidr) > 0
    error_message = "최소 하나 이상의 퍼블릭 서브넷이 필요합니다."
  }
}

variable "private_subnets_cidr" {
  description = "프라이빗 서브넷 CIDR 블록 리스트"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) > 0
    error_message = "최소 하나 이상의 프라이빗 서브넷이 필요합니다."
  }
}

variable "availability_zones" {
  description = "가용영역 리스트"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "고가용성을 위해 최소 2개 이상의 가용영역이 필요합니다."
  }
}

variable "private_subnet_ids" {
    description = "프라이빗 서브넷 ID 리스트"
    type        = list(string)
}

variable "public_subnet_ids" {
    description = "퍼블릭 서브넷 ID 리스트"
    type        = list(string)
}
