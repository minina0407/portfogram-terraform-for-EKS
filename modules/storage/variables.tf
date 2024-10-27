# modules/storage/variables.tf
variable "state_bucket_name" {
  description = "Terraform 상태 파일을 저장할 S3 버킷 이름"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.state_bucket_name))
    error_message = "버킷 이름은 소문자, 숫자, 하이픈, 점만 포함할 수 있으며, 3-63자 사이여야 합니다."
  }
}

variable "thanos_bucket_name" {
  description = "Thanos 메트릭을 저장할 S3 버킷 이름"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.thanos_bucket_name))
    error_message = "버킷 이름은 소문자, 숫자, 하이픈, 점만 포함할 수 있으며, 3-63자 사이여야 합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용될 태그"
  type        = map(string)
  default     = {}
}