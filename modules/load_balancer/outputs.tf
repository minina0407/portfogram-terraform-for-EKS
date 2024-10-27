# modules/load_balancer/outputs.tf
output "load_balancer_id" {
  description = "로드밸런서 ID"
  value       = aws_lb.main.id
}

output "load_balancer_arn" {
  description = "로드밸런서 ARN"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "로드밸런서 DNS 이름"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "대상 그룹 ARN"
  value       = aws_lb_target_group.main.arn
}

output "listener_arn" {
  description = "리스너 ARN"
  value       = aws_lb_listener.main.arn
}

output "security_group_id" {
  description = "로드밸런서 보안 그룹 ID"
  value       = aws_security_group.nlb.id
}

output "zone_id" {
  description = "로드밸런서 Route 53 호스팅 영역 ID"
  value       = aws_lb.main.zone_id
}