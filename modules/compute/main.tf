# modules/compute/main.tf

locals {
  cluster_name = var.cluster_name

  # EKS 관련 태그
  cluster_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    }
  )
}

######
# EKS Cluster
######
resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  version  = var.kubernetes_version
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]

    # CIDR 블록 제한을 통한 보안 강화
    public_access_cidrs     = ["0.0.0.0/0"]  # 프로덕션에서는 회사 IP 대역으로 제한 권장
  }

  # 로깅 설정
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # 암호화 설정
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  tags = local.cluster_tags

  # 클러스터 생성 전 IAM 역할 및 정책이 완전히 생성되도록 보장
  depends_on = [
    var.eks_cluster_role_arn
  ]


}

######
# KMS Key for EKS
######
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS cluster ${local.cluster_name} secrets encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${local.cluster_name}-key"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${local.cluster_name}-key"
  target_key_id = aws_kms_key.eks.key_id
}

######
# Security Group
######
resource "aws_security_group" "cluster" {
  name_prefix = "${local.cluster_name}-cluster-"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(local.cluster_tags, {
    Name = "${local.cluster_name}-cluster-sg"
  })
}

resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.cluster.id
  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster_ingress_webhook" {
  description       = "Allow webhook API traffic"
  security_group_id = aws_security_group.cluster.id
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = [var.vpc_cidr]  # VPC 내부 통신만 허용
}

######
# EKS Node Groups
######
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = var.eks_node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # 노드 그룹 설정
  disk_size      = each.value.disk_size
  instance_types = [each.value.instance_type]
  capacity_type  = "SPOT"  # 비용 최적화를 위한 SPOT 인스턴스 사용

  # 노드 그룹 자동 업데이트 설정
  update_config {
    max_unavailable_percentage = 33  # 업데이트 중 최대 33%까지 노드 사용 불가 허용
  }

  # 노드 그룹 태그 설정
  tags = merge(
    local.cluster_tags,
    {
      "k8s.io/cluster-autoscaler/enabled"                 = "true"
      "k8s.io/cluster-autoscaler/${local.cluster_name}"   = "owned"
      "Name"                                              = "${local.cluster_name}-${each.key}-node"
    }
  )



  depends_on = [
    aws_eks_cluster.main,
    var.eks_node_role_arn
  ]
}

######
# Launch Template
######
resource "aws_launch_template" "main" {
  for_each = var.node_groups

  name_prefix = "${local.cluster_name}-${each.key}-"
  description = "Launch template for EKS managed node group ${each.key}"



  # 블록 디바이스 설정
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = each.value.disk_size
      volume_type          = "gp3"
      delete_on_termination = true
      encrypted            = true
    }
  }

  # 모니터링 설정
  monitoring {
    enabled = true
  }

  # 네트워크 설정
  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [aws_security_group.nodes[each.key].id]
  }

  # 태그 설정
  tags = merge(local.cluster_tags, {
    Name = "${local.cluster_name}-${each.key}-lt"
  })

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.cluster_tags, {
      Name = "${local.cluster_name}-${each.key}-node"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

######
# Node Security Group
######
resource "aws_security_group" "nodes" {
  for_each    = var.node_groups
  name_prefix = "${local.cluster_name}-${each.key}-nodes-"
  description = "Security group for EKS managed node group ${each.key}"
  vpc_id      = var.vpc_id

  tags = merge(local.cluster_tags, {
    Name = "${local.cluster_name}-${each.key}-nodes-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nodes_egress" {
  for_each          = var.node_groups
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.nodes[each.key].id
  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nodes_ingress_self" {
  for_each          = var.node_groups
  description       = "Allow node to communicate with each other"
  security_group_id = aws_security_group.nodes[each.key].id
  type             = "ingress"
  from_port        = 0
  to_port          = 65535
  protocol         = "-1"
  self             = true
}

resource "aws_security_group_rule" "nodes_ingress_cluster" {
  for_each                 = var.node_groups
  description              = "Allow nodes to receive communication from the cluster control plane"
  security_group_id        = aws_security_group.nodes[each.key].id
  source_security_group_id = aws_security_group.cluster.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
}

resource "aws_security_group_rule" "cluster_ingress_nodes" {
  for_each                 = var.node_groups
  description              = "Allow cluster control plane to receive communication from nodes"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.nodes[each.key].id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
}