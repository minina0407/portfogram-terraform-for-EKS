# modules/storage/outputs.tf
output "state_bucket_name" {
  description = "Terraform 상태 버킷 이름"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "Terraform 상태 버킷 ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "thanos_bucket_name" {
  description = "Thanos 메트릭 버킷 이름"
  value       = aws_s3_bucket.thanos.id
}

output "thanos_bucket_arn" {
  description = "Thanos 메트릭 버킷 ARN"
  value       = aws_s3_bucket.thanos.arn
}

output "state_bucket_versioning_status" {
  description = "Terraform 상태 버킷 버저닝 상태"
  value       = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status
}

output "thanos_bucket_versioning_status" {
  description = "Thanos 메트릭 버킷 버저닝 상태"
  value       = aws_s3_bucket_versioning.thanos.versioning_configuration[0].status
}

output "state_bucket_kms_key_arn" {
  description = "Terraform 상태 버킷에 사용된 KMS 키 ARN"
  value       = aws_kms_key.terraform_state.arn
}


