aws_region = "ap-northeast-2"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Subnet Configuration
public_subnets_cidr = [
  "10.0.0.0/20",
  "10.0.16.0/20"
]

private_subnets_cidr = [
  "10.0.128.0/20",
  "10.0.144.0/20"
]

availability_zones = [
  "ap-northeast-2a",
  "ap-northeast-2c"
]

# EKS Cluster Configuration
cluster_name = "portfogram-eks-cluster"
node_groups = {
  "Builders" = {
    name          = "Builders"
    instance_type = "M5.medium"
    disk_size     = 20
    desired_size  = 1
    min_size      = 1
    max_size      = 2
  },
  "Workers" = {
    name          = "Workers"
    instance_type = "t3.medium"
    disk_size     = 20
    desired_size  = 1
    min_size      = 1
    max_size      = 2
  }
}

# state 저장 용 s3 bucket
bucket_name = "portfogram-tf-state"
# Thanos 용 s3 bucket
thanos_bucket_name = "portfogram-thanos"

# IAM Role
eks_cluster_role_arn = "arn:aws:iam::966476688056:role/eks_cluster_role"
eks_node_role_arn = "arn:aws:iam::966476688056:role/eks_node_role"

# Route53
domain_name = "minimeisme.com"