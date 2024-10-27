variable "state_bucket_name" {
  description = "Name of S3 bucket for Terraform state storage"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.state_bucket_name))
    error_message = "The bucket name must contain only lowercase letters, numbers, hyphens, and periods, and must be between 3 and 63 characters long."
  }
}

variable "thanos_bucket_name" {
  description = "Name of S3 bucket for Thanos metrics storage"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-.]*[a-z0-9]$", var.thanos_bucket_name))
    error_message = "The bucket name must contain only lowercase letters, numbers, hyphens, and periods, and must be between 3 and 63 characters long."
  }
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}