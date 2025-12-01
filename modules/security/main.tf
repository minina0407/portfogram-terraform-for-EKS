# modules/security/main.tf

locals {
  # EKS 클러스터 태그 (보안 그룹에 사용)
  cluster_tags = merge(
    var.tags,
    {
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

######
# IAM Roles
######
resource "aws_iam_role" "cluster" {
  name = "${var.name_prefix}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "node" {
  name = "${var.name_prefix}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node.name
}

######
# Security Groups - Cluster
######
resource "aws_security_group" "cluster" {
  name_prefix = "${var.cluster_name}-sg-"
  description = "EKS cluster security group"
  vpc_id      = var.vpc_id

  tags = merge(local.cluster_tags, {
    Name = "${var.cluster_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_egress" {
  description       = "Allow all egress traffic from cluster"
  security_group_id = aws_security_group.cluster.id
  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster_ingress_webhook" {
  description       = "Allow webhook API traffic to cluster"
  security_group_id = aws_security_group.cluster.id
  type             = "ingress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = [var.vpc_cidr]  # VPC 내부 통신만 허용
}

######
# Security Groups - Nodes
######
resource "aws_security_group" "nodes" {
  for_each    = var.node_groups
  name_prefix = "${var.cluster_name}-${each.key}-nodes-"
  description = "Security group for EKS managed node group ${each.key}"
  vpc_id      = var.vpc_id

  tags = merge(local.cluster_tags, {
    Name = "${var.cluster_name}-${each.key}-nodes-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nodes_egress" {
  for_each          = var.node_groups
  description       = "Allow all egress traffic from nodes"
  security_group_id = aws_security_group.nodes[each.key].id
  type             = "egress"
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nodes_ingress_self" {
  for_each          = var.node_groups
  description       = "Allow nodes to communicate with each other"
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

