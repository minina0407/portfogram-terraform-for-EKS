
# modules/load_balancer/variables.tf
variable "name_prefix" {
  description = "리소스 이름에 사용될 접두사"
  type        = string
}

variable "vpc_id" {
  description = "로드밸런서가 생성될 VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "로드밸런서가 생성될 서브넷 ID 목록"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "고가용성을 위해 최소 2개의 서브넷이 필요합니다."
  }
}

variable "target_port" {
  description = "대상 그룹 포트"
  type        = number

  validation {
    condition     = var.target_port > 0 && var.target_port <= 65535
    error_message = "유효한 포트 번호를 입력하세요 (1-65535)."
  }
}

variable "listener_port" {
  description = "리스너 포트"
  type        = number

  validation {
    condition     = var.listener_port > 0 && var.listener_port <= 65535
    error_message = "유효한 포트 번호를 입력하세요 (1-65535)."
  }
}

variable "health_check_interval" {
  description = "헬스 체크 간격 (초)"
  type        = number
  default     = 30

  validation {
    condition     = var.health_check_interval >= 5 && var.health_check_interval <= 300
    error_message = "헬스 체크 간격은 5-300초 사이여야 합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용될 태그"
  type        = map(string)
  default     = {}
}

variable "cluster_endpoint" {
    description = "EKS 클러스터 엔드포인트"
    type        = string
}