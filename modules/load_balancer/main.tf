
# modules/load_balancer/main.tf
resource "aws_security_group" "nlb" {
  name_prefix = "${var.name_prefix}-nlb-"
  description = "Security group for Network Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.listener_port
    to_port     = var.listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nlb-sg"
  })


}

resource "aws_lb" "main" {
  name               = "${var.name_prefix}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_cross_zone_load_balancing = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nlb"
  })
}

resource "aws_lb_target_group" "main" {
  name        = "${var.name_prefix}-tg"
  port        = var.target_port
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    protocol           = "TCP"
    port               = "traffic-port"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-tg"
  })


}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}