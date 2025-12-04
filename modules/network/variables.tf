# modules/network/variables.tf
# 네트워크 모듈 변수 정의

variable "name_prefix" {
  description = "리소스 이름에 사용할 접두사"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록 (예: 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR block must be a valid CIDR string such as 10.0.0.0/16."
  }
}

variable "public_subnets_cidr" {
  description = "퍼블릭 서브넷 CIDR 블록 목록 (빈 리스트면 Public 서브넷 생성 안 함)"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnets_cidr) == 0 || length(var.public_subnets_cidr) >= 1
    error_message = "Public subnet CIDR list must be either empty or contain at least one valid CIDR block."
  }
}

variable "private_subnets_cidr" {
  description = "프라이빗 서브넷 CIDR 블록 목록 (필수, 최소 하나 이상)"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) > 0
    error_message = "At least one private subnet CIDR block must be provided."
  }
}

variable "availability_zones" {
  description = "가용영역 목록 (고가용성을 위해 최소 2개 필수)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required for high availability."
  }
}

variable "tags" {
  description = "모든 리소스에 적용할 태그 맵"
  type        = map(string)
  default     = {}
}
