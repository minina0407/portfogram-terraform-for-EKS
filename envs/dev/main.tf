terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

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

  default_tags {
    tags = local.common_tags
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

module "storage" {
  source = "../../modules/storage"

  state_bucket_name  = "${local.name_prefix}-tf-state-${random_string.suffix.result}" // terraform 상태 저자용 s3 버킷
  thanos_bucket_name = "${local.name_prefix}-thanos-${random_string.suffix.result}"   // 모니터링용 장기저장소 

  tags = {
    Service = "Storage"
  }
}

module "network" { // 네트워크 인프라를 독립 모듈로 분리 
  // 다른 모듈들이 Vpc / 서브넷 ID를 참조하므로 먼저 생성 필요
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones

  tags = {
    Service = "Network"
  }
}

module "security" { //보안 관련 리소스를 한곳에서 관리 
  source = "../../modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id // 네트워크 모듈 출력값을 사용 , 순환 참조피하기 위해서 네트워크를 먼저 생성 
  vpc_cidr    = var.vpc_cidr
  // EKS 클러스터와 노드 그룹에 필요한 IAM 권한 구성에 사용 
  cluster_name = "${local.name_prefix}-cluster"
  node_groups  = var.node_groups

  tags = {
    Service = "Security"
  }

  depends_on = [module.network]
}

module "compute" {
  source = "../../modules/compute"

  name_prefix        = local.name_prefix
  cluster_name       = "${local.name_prefix}-cluster"
  kubernetes_version = var.kubernetes_version

  vpc_id = module.network.vpc_id
  // 노드 그룹 배치를 private subnet 에서만 가능하도록 제한 하여 보안 강화 
  subnet_ids         = module.network.private_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids

  eks_cluster_role_arn          = module.security.eks_cluster_role_arn
  eks_node_role_arn             = module.security.eks_node_role_arn
  eks_cluster_security_group_id = module.security.eks_cluster_security_group_id
  node_security_group_ids       = module.security.node_security_group_ids
  node_groups                   = var.node_groups

  tags = {
    Service = "Compute"
  }

  depends_on = [module.network, module.security] // 네트워크 , 보안 모듈의 출력값을 모두 사용하므로 명시적 의존성 필요 
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
  // Pulic subnet에 배치해 인터넷에서 접근 가능하도록 설정 
  subnet_ids    = module.network.public_subnet_ids
  target_port   = var.target_port
  listener_port = var.listener_port
  // EKS 클러스터 앤드포인트를 참조해 로드 밸런서를 클러스터와 연결
  cluster_endpoint = module.compute.cluster_endpoint

  tags = {
    Service = "LoadBalancer"
  }

  depends_on = [module.compute] // 순환 참조 방지를 위해 클러스터 생성 후 로드 밸런서 생성 
}
// main.tf에서는 모듈 호출 및 의존성 관리만 담당하고 각 모듈의 내부 로직은 독립적으로 관리 
// 이로 인해 재사용성 ( 환경별로 동일 구조 재사용 ). 일관성 ( name_prefix 사용 , common_tags 사용 ) 유지 가능 

