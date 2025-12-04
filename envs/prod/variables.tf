# env/dev/variables.tf
# 개발 환경에 필요한 Terraform 변수 정의
# 이 파일은 env/dev/main.tf와 terraform.tfvars에서 사용되는 변수들의 타입과 제약조건을 정의합니다.

# =============================================================================
# 프로젝트 기본 설정
# =============================================================================
variable "project_name" {
  description = "프로젝트 이름 (리소스 이름 prefix에 사용, 소문자, 숫자, 하이픈만 허용)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "aws_region" {
  description = "AWS 리전 (예: ap-northeast-2, ap-southeast-1)"
  type        = string
  default     = "ap-northeast-2" # 서울 리전 기본값
}

# =============================================================================
# 네트워크 설정
# =============================================================================
variable "vpc_cidr" {
  description = "VPC CIDR 블록 (예: 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR block must be a valid CIDR string such as 10.0.0.0/16."
  }
}

variable "public_subnets_cidr" {
  description = "퍼블릭 서브넷 CIDR 블록 목록 (로드밸런서, NAT 게이트웨이 등 인터넷 접근이 필요한 리소스용)"
  type        = list(string)

  validation {
    condition     = length(var.public_subnets_cidr) > 0
    error_message = "At least one public subnet CIDR block must be provided."
  }
}

variable "private_subnets_cidr" {
  description = "프라이빗 서브넷 CIDR 블록 목록 (EKS 노드 그룹 등 외부에 직접 노출되지 않는 리소스용)"
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

# =============================================================================
# EKS 클러스터 설정
# =============================================================================
variable "kubernetes_version" {
  description = "Kubernetes 버전 (1.25 ~ 1.28 사이, 형식: 1.XX)"
  type        = string
  default     = "1.28"

  validation {
    condition     = can(regex("^1\\.(2[567]|28)$", var.kubernetes_version))
    error_message = "Kubernetes 버전은 1.25 ~ 1.28 사이여야 합니다."
  }
}

variable "node_groups" {
  description = "EKS 노드 그룹 설정 맵 (각 노드 그룹별 스케일링 정책 및 인스턴스 타입 정의)"
  type = map(object({
    desired_size  = number # 목표 노드 수
    max_size      = number # 최대 노드 수
    min_size      = number # 최소 노드 수
    disk_size     = number # 디스크 크기 (GB, 최소 20GB)
    instance_type = string # EC2 인스턴스 타입 (예: t3.medium)
  }))

  validation {
    condition = alltrue([
      for ng in var.node_groups : (
        ng.min_size <= ng.desired_size &&
        ng.desired_size <= ng.max_size &&
        ng.disk_size >= 20
      )
    ])
    error_message = "Node group configuration is invalid; ensure min_size <= desired_size <= max_size and disk_size is at least 20 GB."
  }
}

# =============================================================================
# 로드밸런서 설정
# =============================================================================
variable "target_port" {
  description = "대상 그룹 포트 (애플리케이션이 실제로 수신하는 포트, 1-65535)"
  type        = number

  validation {
    condition     = var.target_port > 0 && var.target_port <= 65535
    error_message = "Target port must be between 1 and 65535."
  }
}

variable "listener_port" {
  description = "리스너 포트 (클라이언트가 연결하는 포트, 일반적으로 80 또는 443, 1-65535)"
  type        = number

  validation {
    condition     = var.listener_port > 0 && var.listener_port <= 65535
    error_message = "Listener port must be between 1 and 65535."
  }
}
