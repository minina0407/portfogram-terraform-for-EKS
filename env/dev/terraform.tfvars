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
  "ng-1" = {
    name          = "ng-1"
    instance_type = "t3.medium"
    disk_size     = 20
    desired_size  = 1
    min_size      = 1
    max_size      = 2
  },
  "ng-2" = {
    name          = "ng-2"
    instance_type = "t3.medium"
    disk_size     = 20
    desired_size  = 1
    min_size      = 1
    max_size      = 2
  }
}

# s3 bucket
bucket_name = "portfogram-tf-state"
domain_name = "minimeisme.com"