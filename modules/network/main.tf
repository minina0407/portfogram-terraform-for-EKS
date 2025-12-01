# modules/network/main.tf
# 네트워크 인프라 모듈: VPC, 서브넷, 게이트웨이, 라우팅 테이블 등 네트워크 리소스 생성

# =============================================================================
# Locals: 지역 변수 정의 (재사용 및 가독성 향상)
# =============================================================================
locals {
  # 가용영역 수 (모든 AZ에 Private 서브넷 생성)
  az_count = length(var.availability_zones)

  # VPC CIDR 블록 (재사용성 향상)
  vpc_cidr = var.vpc_cidr

  # Public 서브넷 생성 여부 결정 (조건부 생성)
  create_public_subnets = length(var.public_subnets_cidr) > 0

  # Public 서브넷 개수 (Public 서브넷은 선택적이므로 개수 확인)
  public_az_count = length(var.public_subnets_cidr)
}

# =============================================================================
# VPC 리소스
# =============================================================================
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  # DNS 설정: EKS와 EC2 인스턴스에서 DNS 호스트명 사용 가능하도록 활성화
  enable_dns_hostnames = true # DNS 호스트명 활성화 (예: ip-10-0-1-1.ec2.internal)
  enable_dns_support   = true # DNS 해석 활성화 (Route 53 Resolver 사용)

  tags = merge(var.tags, {
    Name                                       = "${var.name_prefix}-vpc"
    "kubernetes.io/cluster/${var.name_prefix}" = "shared" # EKS 클러스터가 VPC를 인식하도록 태그
  })
}

# =============================================================================
# Public 서브넷 (인터넷 접근이 필요한 리소스용: 로드밸런서, NAT 게이트웨이 등)
# =============================================================================
resource "aws_subnet" "public" {
  count             = local.create_public_subnets ? local.public_az_count : 0
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  # Public IP 자동 할당: 이 서브넷에 생성되는 인스턴스에 자동으로 Public IP 할당
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name                     = "${var.name_prefix}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1" # Kubernetes 로드밸런서가 이 서브넷 사용 가능
  })

  depends_on = [aws_vpc.main]
}

# =============================================================================
# Private 서브넷 (외부에 직접 노출되지 않는 리소스용: EKS 노드 그룹 등)
# =============================================================================
resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  # Private IP만 사용 (Public IP 자동 할당 없음)

  tags = merge(var.tags, {
    Name                              = "${var.name_prefix}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb" = "1" # Kubernetes 내부 로드밸런서가 이 서브넷 사용 가능
  })

  depends_on = [aws_vpc.main]
}

# =============================================================================
# Internet Gateway (VPC와 인터넷 간 통신을 위한 게이트웨이)
# =============================================================================
resource "aws_internet_gateway" "main" {
  count  = local.create_public_subnets ? 1 : 0 # Public 서브넷이 있을 때만 생성
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })

  depends_on = [aws_vpc.main]
}

# =============================================================================
# Elastic IP (NAT Gateway에 할당할 정적 Public IP)
# =============================================================================
resource "aws_eip" "nat" {
  count  = local.create_public_subnets ? local.az_count : 0 # 각 AZ당 하나씩 생성
  domain = "vpc"                                            # VPC 도메인에서 사용 (기본값)

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-eip-${count.index + 1}"
  })

  # EIP는 VPC와 독립적으로 생성되지만 명시적으로 의존성 표시
  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# NAT Gateway (Private 서브넷의 아웃바운드 인터넷 접근 제공)
# =============================================================================
resource "aws_nat_gateway" "main" {
  count         = local.create_public_subnets ? local.az_count : 0 # 각 AZ당 하나씩 생성
  allocation_id = aws_eip.nat[count.index].id                      # 해당 AZ의 EIP 할당
  subnet_id     = aws_subnet.public[count.index].id                # Public 서브넷에 배치 (인터넷 접근 필요)

  # Internet Gateway가 생성된 후에 NAT Gateway 생성 (명시적 의존성)
  depends_on = [aws_internet_gateway.main, aws_eip.nat]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })
}

# =============================================================================
# Public Route Table (모든 Public 서브넷이 공유하는 라우트 테이블)
# =============================================================================
resource "aws_route_table" "public" {
  count  = local.create_public_subnets ? 1 : 0 # Public 서브넷이 있을 때만 생성
  vpc_id = aws_vpc.main.id

  # 모든 트래픽(0.0.0.0/0)을 Internet Gateway로 라우팅
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# Private Route Table (각 AZ별로 독립적인 라우트 테이블)
# =============================================================================
resource "aws_route_table" "private" {
  count  = local.az_count # 각 AZ당 하나씩 생성 (고가용성 확보)
  vpc_id = aws_vpc.main.id

  # NAT 게이트웨이가 있을 때만 아웃바운드 인터넷 트래픽 라우트 추가
  # dynamic 블록을 사용하여 조건부 라우트 생성
  dynamic "route" {
    for_each = local.create_public_subnets ? [1] : [] # Public 서브넷이 있으면 라우트 추가
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id # 해당 AZ의 NAT Gateway 사용
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
  })

  depends_on = [aws_nat_gateway.main, aws_vpc.main]
}

# =============================================================================
# Route Table Association - Public (Public 서브넷과 Public Route Table 연결)
# =============================================================================
resource "aws_route_table_association" "public" {
  count          = local.create_public_subnets ? local.public_az_count : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id # 모든 Public 서브넷이 하나의 Route Table 공유

  depends_on = [aws_subnet.public, aws_route_table.public]
}

# =============================================================================
# Route Table Association - Private (Private 서브넷과 해당 AZ의 Private Route Table 연결)
# =============================================================================
resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id # 각 AZ별로 독립적인 Route Table 사용

  depends_on = [aws_subnet.private, aws_route_table.private]
}
