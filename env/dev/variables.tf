variable "project_name" {
    description = "프로젝트 이름"
    type        = string

    validation {
        condition     = can(regex("^[a-z0-9-]+$", var.project_name))
        error_message = "프로젝트 이름은 소문자, 숫자, 하이픈만 포함할 수 있습니다."
    }
}

variable "aws_region" {
    description = "AWS 리전"
    type        = string
    default     = "ap-northeast-2"
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

variable "kubernetes_version" {
    description = "EKS 클러스터 버전"
    type        = string
    default     = "1.27"

    validation {
        condition     = can(regex("^1\\.(2[567]|28)$", var.kubernetes_version))
        error_message = "지원되는 쿠버네티스 버전은 1.25-1.28입니다."
    }
}

variable "node_groups" {
    description = "EKS 노드 그룹 설정"
    type = map(object({
        desired_size  = number
        max_size      = number
        min_size      = number
        disk_size     = number
        instance_type = string
    }))

    validation {
        condition = alltrue([
            for ng in var.node_groups : (
            ng.min_size <= ng.desired_size &&
            ng.desired_size <= ng.max_size &&
            ng.disk_size >= 20
            )
        ])
        error_message = "노드 그룹 설정이 올바르지 않습니다."
    }
}

variable "target_port" {
    description = "로드밸런서 타겟 포트"
    type        = number

    validation {
        condition     = var.target_port > 0 && var.target_port <= 65535
        error_message = "유효한 포트 번호를 입력하세요 (1-65535)."
    }
}

variable "listener_port" {
    description = "로드밸런서 리스너 포트"
    type        = number

    validation {
        condition     = var.listener_port > 0 && var.listener_port <= 65535
        error_message = "유효한 포트 번호를 입력하세요 (1-65535)."
    }
}

variable "backup_retention_days" {
    description = "백업 보관 기간"
    type        = number
    default     = 7

    validation {
        condition     = var.backup_retention_days > 0
        error_message = "백업 보관 기간은 1일 이상이어야 합니다."
    }
}

variable "health_check_interval" {
    description = "로드밸런서 헬스체크 간격"
    type        = number
    default     = 30

    validation {
        condition     = var.health_check_interval > 0
        error_message = "헬스체크 간격은 1초 이상이어야 합니다."
    }
}