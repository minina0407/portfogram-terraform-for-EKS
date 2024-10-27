# AWS 네트워크 로드 밸런서 (NLB) 구성
resource "aws_lb" "network" {
  name               = "portfogram-nlb"  # 로드 밸런서의 이름
  internal           = false             # 외부에 공개된 로드 밸런서 설정
  load_balancer_type = "network"         # 로드 밸런서 유형 설정 (네트워크 유형)
  subnets            = var.subnets       # 로드 밸런서가 배치될 서브넷
  enable_cross_zone_load_balancing = true  # 크로스-존 로드 밸런싱 활성화
}

# 첫 번째 대상 그룹 구성 (HTTPS 트래픽용)
resource "aws_lb_target_group" "tg1" {
  name     = "tg1"            # 대상 그룹의 이름
  port     = 443              # HTTPS 포트 설정
  protocol = "TCP"            # 통신 프로토콜 설정
  vpc_id   = var.vpc_id       # 대상 그룹이 위치할 VPC ID

  # 건강 검사 설정
  health_check {
    protocol = "TCP"          # 건강 검사 프로토콜
    port     = "443"          # 건강 검사 포트
    interval = 30             # 검사 간격 (초)
    healthy_threshold   = 3   # 건강 상태로 판단하기 위한 연속 성공 횟수
    unhealthy_threshold = 3   # 비건강 상태로 판단하기 위한 연속 실패 횟수
  }
}

# 두 번째 대상 그룹 구성 (HTTP 트래픽용)
resource "aws_lb_target_group" "tg2" {
  name     = "tg2"            # 대상 그룹의 이름
  port     = 80               # HTTP 포트 설정
  protocol = "TCP"            # 통신 프로토콜 설정
  vpc_id   = var.vpc_id       # 대상 그룹이 위치할 VPC ID

  # 건강 검사 설정
  health_check {
    protocol = "TCP"          # 건강 검사 프로토콜
    port     = "80"           # 건강 검사 포트
    interval = 30             # 검사 간격 (초)
    healthy_threshold   = 3   # 건강 상태로 판단하기 위한 연속 성공 횟수
    unhealthy_threshold = 3   # 비건강 상태로 판단하기 위한 연속 실패 횟수
  }
}

# HTTPS 트래픽을 처리하기 위한 리스너 구성
resource "aws_lb_listener" "listener1" {
  load_balancer_arn = aws_lb.network.arn  # NLB의 ARN
  protocol          = "TCP"               # 통신 프로토콜 설정
  port              = 443                 # 리스닝 포트 (HTTPS)

  # 기본 액션 설정: 트래픽을 첫 번째 대상 그룹으로 전달
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}

# HTTP 트래픽을 처리하기 위한 리스너 구성
resource "aws_lb_listener" "listener2" {
  load_balancer_arn = aws_lb.network.arn  # NLB의 ARN
  protocol          = "TCP"               # 통신 프로토콜 설정
  port              = 80                  # 리스닝 포트 (HTTP)

  # 기본 액션 설정: 트래픽을 두 번째 대상 그룹으로 전달
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg2.arn
  }
}

resource "aws_route53_zone" "minimeisme" {
  name = var.domain_name
}

# Route 53 A 레코드 설정 (NLB와 연결)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.minimeisme.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.network.dns_name
    zone_id                = aws_lb.network.zone_id
    evaluate_target_health = true
  }
}