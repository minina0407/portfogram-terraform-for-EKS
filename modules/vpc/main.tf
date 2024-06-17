# VPC 생성
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr                # VPC의 CIDR 블록
  enable_dns_support   = true              # DNS 지원 활성화
  enable_dns_hostnames = true              # DNS 호스트네임 활성화

  tags = {
    Name = "portfogram-vpc"                # VPC에 태그 추가
  }
}

# 공용 서브넷 생성
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr)  # 공용 서브넷 개수
  vpc_id            = aws_vpc.main.id                  # 생성한 VPC ID
  cidr_block        = var.public_subnets_cidr[count.index]  # 각 서브넷 CIDR
  availability_zone = var.availability_zones[count.index]   # 사용할 가용 영역
  map_public_ip_on_launch = true  # 인스턴스 시작 시 공개 IP 자동 할당

  tags = {
    Name = "portfogram-vpc-public-${var.availability_zones[count.index]}"  # 서브넷에 태그 추가
  }
}

# 개인 서브넷 생성
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)  # 개인 서브넷 개수
  vpc_id            = aws_vpc.main.id                  # 생성한 VPC ID
  cidr_block        = var.private_subnets_cidr[count.index]  # 각 서브넷 CIDR
  availability_zone = var.availability_zones[count.index]   # 사용할 가용 영역

  tags = {
    Name = "portfogram-vpc-private-${var.availability_zones[count.index]}"  # 서브넷에 태그 추가
  }
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "main" {
  count      = length(var.public_subnets_cidr)  # NAT 게이트웨이 개수 (공용 서브넷 개수에 맞춤)
  subnet_id  = aws_subnet.public[count.index].id  # NAT 게이트웨이를 배치할 서브넷 ID
  allocation_id = aws_eip.nat[count.index].id     # NAT 게이트웨이에 사용할 탄력적 IP ID

  tags = {
    Name = "NAT-Gateway-${var.availability_zones[count.index]}"  # NAT 게이트웨이에 태그 추가
  }
}

# 탄력적 IP 생성
resource "aws_eip" "nat" {
  count = length(var.availability_zones)  # 가용 영역 수 만큼 탄력적 IP 생성
  domain = "vpc"                          # domain
  # domain 속성은 vpc or standard 중 하나의 값을 가질 수 있음

}

# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id                 # 인터넷 게이트웨이를 연결할 VPC ID
}

# 공용 서브넷용 라우트 테이블 생성
resource "aws_route_table" "public" {
  count  = length(var.public_subnets_cidr)  # 공용 서브넷 수 만큼 라우트 테이블 생성
  vpc_id = aws_vpc.main.id                  # 라우트 테이블을 연결할 VPC ID
}

# 공용 서브넷에서 인터넷으로의 라우트 설정
resource "aws_route" "internet_access" {
  count                  = length(var.public_subnets_cidr)  # 공용 서브넷 수 만큼 라우트 설정
  route_table_id         = aws_route_table.public[count.index].id  # 사용할 라우트 테이블 ID
  destination_cidr_block = "0.0.0.0/0"  # 모든 외부 트래픽 (인터넷 트래픽)
  gateway_id             = aws_internet_gateway.main.id     # 인터넷 게이트웨이 ID
}

# 공용 서브넷과 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)  # 공용 서브넷 수 만큼 연결
  subnet_id      = aws_subnet.public[count.index].id  # 연결할 서브넷 ID
  route_table_id = aws_route_table.public[count.index].id  # 연결할 라우트 테이블 ID
}
