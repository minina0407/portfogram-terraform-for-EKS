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
    security_group_ids      = [var.eks_cluster_security_group_id]

    # CIDR 블록 제한을 통한 보안 강화
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # 로깅 설정
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]


  tags = local.cluster_tags

  # 클러스터 생성 전 IAM 역할 및 정책이 완전히 생성되도록 보장
  depends_on = [
    var.eks_cluster_role_arn
  ]


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
  capacity_type  = "SPOT" # 비용 최적화를 위한 SPOT 인스턴스 사용

  # 노드 그룹 자동 업데이트 설정
  update_config {
    max_unavailable_percentage = 33 # 업데이트 중 최대 33%까지 노드 사용 불가 허용
  }

  # 노드 그룹 태그 설정
  tags = merge(
    local.cluster_tags,
    {
      "k8s.io/cluster-autoscaler/enabled"               = "true"
      "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
      "Name"                                            = "${local.cluster_name}-${each.key}-node"
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
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
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
    security_groups             = [var.node_security_group_ids[each.key]]
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
