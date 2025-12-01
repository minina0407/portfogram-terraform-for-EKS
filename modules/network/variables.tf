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
    error_message = "유효한 CIDR 블록 형식을 입력해주세요 (예: 10.0.0.0/16)."
  }
}

variable "public_subnets_cidr" {
  description = "퍼블릭 서브넷 CIDR 블록 목록 (빈 리스트면 Public 서브넷 생성 안 함)"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnets_cidr) == 0 || length(var.public_subnets_cidr) >= 1
    error_message = "퍼블릭 서브넷 CIDR는 빈 리스트이거나 최소 하나 이상의 CIDR 블록을 포함해야 합니다."
  }
}

variable "private_subnets_cidr" {
  description = "프라이빗 서브넷 CIDR 블록 목록 (필수, 최소 하나 이상)"
  type        = list(string)

  validation {
    condition     = length(var.private_subnets_cidr) > 0
    error_message = "최소 하나 이상의 프라이빗 서브넷 CIDR 블록이 필요합니다."
  }
}

variable "availability_zones" {
  description = "가용영역 목록 (고가용성을 위해 최소 2개 필수)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "고가용성을 위해 최소 2개 이상의 가용영역이 필요합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용할 태그 맵"
  type        = map(string)
  default     = {}
}