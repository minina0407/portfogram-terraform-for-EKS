output "lb_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.network.dns_name
}