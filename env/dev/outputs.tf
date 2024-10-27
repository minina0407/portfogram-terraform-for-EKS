output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.compute.cluster_endpoint
}


output "eks_cluster_name" {
  description = "EKS 클러스터 이름"
  value       = module.compute.cluster_name
}



output "tf_state_bucket" {
  description = "Terraform 상태 파일 버킷 이름"
  value       = module.storage.state_bucket_name
}
