# modules/security/outputs.tf

# IAM Role Outputs
output "cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN"
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "EKS 클러스터 IAM 역할 이름"
  value       = aws_iam_role.cluster.name
}

output "node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "EKS 노드 IAM 역할 이름"
  value       = aws_iam_role.node.name
}

# Security Group Outputs
output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.cluster.id
}

output "cluster_security_group_arn" {
  description = "EKS 클러스터 보안 그룹 ARN"
  value       = aws_security_group.cluster.arn
}

output "node_security_group_ids" {
  description = "EKS 노드 보안 그룹 ID 맵 (노드 그룹 이름을 키로 사용)"
  value       = { for k, v in aws_security_group.nodes : k => v.id }
}

# Backward compatibility outputs
output "eks_cluster_role_arn" {
  description = "EKS 클러스터 IAM 역할 ARN (하위 호환성)"
  value       = aws_iam_role.cluster.arn
}

output "eks_node_role_arn" {
  description = "EKS 노드 IAM 역할 ARN (하위 호환성)"
  value       = aws_iam_role.node.arn
}

output "eks_cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID (하위 호환성)"
  value       = aws_security_group.cluster.id
}