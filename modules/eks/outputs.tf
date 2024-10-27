output "cluster_id" {
  value       = aws_eks_cluster.main.id
  description = "The ID of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint for API server"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].security_group_ids
  description = "Security group IDs attached to the cluster control plane."
}

output "node_group_statuses" {
  value = { for ng in aws_eks_node_group.main : ng.node_group_name => ng.status }
  description = "Status of each EKS node group"
}
