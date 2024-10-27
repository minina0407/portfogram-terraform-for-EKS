variable "name_prefix" {
    description = "리소스 이름에 사용될 접두사"
    type        = string
}

variable "vpc_cidr" {
    description = "VPC에 사용될 CIDR 블록"
    type        = string

    validation {
        condition     = can(cidrhost(var.vpc_cidr, 0))
        error_message = "유효한 CIDR 블록을 입력하세요."
    }
}

variable "public_subnets_cidr" {
    description = "퍼블릭 서브넷용 CIDR 블록 목록"
    type        = list(string)

    validation {
        condition     = length(var.public_subnets_cidr) > 0
        error_message = "최소 하나 이상의 퍼블릭 서브넷 CIDR이 필요합니다."
    }
}

variable "private_subnets_cidr" {
    description = "프라이빗 서브넷용 CIDR 블록 목록"
    type        = list(string)

    validation {
        condition     = length(var.private_subnets_cidr) > 0
        error_message = "최소 하나 이상의 프라이빗 서브넷 CIDR이 필요합니다."
    }
}

variable "availability_zones" {
    description = "사용할 가용영역 목록"
    type        = list(string)

    validation {
        condition     = length(var.availability_zones) >= 2
        error_message = "고가용성을 위해 최소 2개의 가용영역이 필요합니다."
    }
}

variable "tags" {
    description = "모든 리소스에 적용될 태그"
    type        = map(string)
    default     = {}
}
