# environments/dev/terraform.tfvars

#####
# 프로젝트 기본 설정
#####
project_name = "my-project"
aws_region   = "ap-northeast-2"

#####
# 네트워크 설정
#####
# VPC CIDR은 개발 환경에 적합한 크기로 설정
vpc_cidr = "10.0.0.0/16"

# 각 가용영역당 하나의 public/private 서브넷
public_subnets_cidr  = [
  "10.0.0.0/24",   # ap-northeast-2a
  "10.0.1.0/24"    # ap-northeast-2b
]

private_subnets_cidr = [
  "10.0.10.0/24",  # ap-northeast-2a
  "10.0.11.0/24"   # ap-northeast-2b
]

availability_zones = [
  "ap-northeast-2a",
  "ap-northeast-2b"
]

#####
# EKS 클러스터 설정
#####
kubernetes_version = "1.27"

# 개발 환경에 적합한 노드 그룹 설정
node_groups = {
  app = {
    desired_size  = 2      # 일반적인 개발 워크로드를 위한 크기
    min_size      = 1      # 비용 최적화를 위한 최소 크기
    max_size      = 4      # 버퍼를 위한 최대 크기
    disk_size     = 30     # GB
    instance_type = "t3.medium"  # 개발용 인스턴스 타입
  }

  monitoring = {
    desired_size  = 1
    min_size      = 1
    max_size      = 2
    disk_size     = 50     # 모니터링 도구를 위한 더 큰 디스크
    instance_type = "t3.large"  # 모니터링용 더 큰 인스턴스
  }
}

#####
# 로드밸런서 설정
#####
target_port    = 80    # 애플리케이션 포트
listener_port  = 443   # HTTPS 리스너 포트

#####
# S3 버킷 설정
# 버킷 이름은 글로벌하게 유니크해야 하므로, 실제 사용시 적절히 수정 필요
#####
state_bucket_name = "my-project-dev-tf-state"    # random suffix는 main.tf에서 추가됨
thanos_bucket_name = "my-project-dev-thanos"     # random suffix는 main.tf에서 추가됨

#####
# 태그 설정
#####
tags = {
  Environment = "dev"
  Project     = "my-project"
  Team        = "devops"
  ManagedBy   = "Terraform"
  CreatedBy   = "terraform-config"
}

#####
# 로드밸런서 추가 설정
#####
health_check_interval = 30  # 초 단위

#####
# 백업 설정
#####
backup_retention_days = 7   # 개발 환경은 7일간 백업 보관