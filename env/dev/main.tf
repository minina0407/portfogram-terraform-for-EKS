locals {
  environment = "dev"
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "storage" {
  source = "../../modules/storage"

  state_bucket_name  = "${local.name_prefix}-tf-state-${random_string.suffix.result}"
  thanos_bucket_name = "${local.name_prefix}-thanos-${random_string.suffix.result}"

  tags = {
    Service = "Storage"
  }
}

module "security" {
  source = "../../modules/security"

  name_prefix = local.name_prefix
  vpc_id     = module.network.vpc_id
  eks_cluster_role_arn = module.security.eks_cluster_role_arn
  eks_node_role_arn    = module.security.eks_node_role_arn

  tags = {
    Service = "Security"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnets_cidr = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones  = var.availability_zones

  tags = {
    Service = "Network"
  }
}

module "compute" {
  source = "../../modules/compute"

  name_prefix = local.name_prefix
  vpc_cidr = var.vpc_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones = var.availability_zones
  public_subnets_cidr = var.public_subnets_cidr
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids = module.network.public_subnet_ids
  cluster_name = "${local.name_prefix}-cluster"
  kubernetes_version = var.kubernetes_version

  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.private_subnet_ids

  eks_cluster_role_arn = module.security.eks_cluster_role_arn
  eks_node_role_arn    = module.security.eks_node_role_arn
  eks_cluster_security_group_id = module.security.eks_cluster_security_group_id
  node_groups = var.node_groups

  tags = {
    Service = "Compute"
  }

  depends_on = [module.network, module.security]
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  name_prefix    = local.name_prefix
  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.public_subnet_ids
  target_port    = var.target_port
  listener_port  = var.listener_port
  cluster_endpoint = module.compute.cluster_endpoint

  tags = {
    Service = "LoadBalancer"
  }

  depends_on = [module.compute]
}