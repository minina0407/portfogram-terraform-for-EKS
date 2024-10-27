
# modules/security/outputs.tf
output "cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.cluster.id
}

output "cluster_security_group_arn" {
  description = "EKS 클러스터 보안 그룹 ARN"
  value       = aws_security_group.cluster.arn
}

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
output "cluster_policy_attachment_ids" {
  description = "EKS 클러스터 정책 연결 ID 목록"
  value       = aws_iam_role_policy_attachment.cluster_policy.id
}

output "node_policy_attachment_ids" {
  description = "EKS 노드 정책 연결 ID 목록"
  value       = [for attachment in aws_iam_role_policy_attachment.node_policy : attachment.id]
}

output "eks_node_role_arn" {
    description = "EKS 노드 IAM 역할 ARN"
    value       = aws_iam_role.node.arn
}

output "eks_cluster_role_arn" {
    description = "EKS 클러스터 IAM 역할 ARN"
    value       = aws_iam_role.cluster.arn
}
# eks_cluster_security_group_id
output "eks_cluster_security_group_id" {
  description = "EKS 클러스터 보안 그룹 ID"
  value       = aws_security_group.cluster.id
}