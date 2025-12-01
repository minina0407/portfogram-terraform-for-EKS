
# modules/network/outputs.tf
output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "생성된 퍼블릭 서브넷 ID 목록"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "생성된 프라이빗 서브넷 ID 목록"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "생성된 NAT 게이트웨이 ID 목록"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_id" {
  description = "퍼블릭 라우트 테이블 ID"
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "internet_gateway_id" {
  description = "인터넷 게이트웨이 ID"
  value       = length(aws_internet_gateway.main) > 0 ? aws_internet_gateway.main[0].id : null
}

output "private_route_table_ids" {
  description = "프라이빗 라우트 테이블 ID 목록"
  value       = aws_route_table.private[*].id
}