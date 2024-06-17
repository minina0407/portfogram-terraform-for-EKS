output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "lb_dns_name" {
  value = module.lb.lb_dns_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}
