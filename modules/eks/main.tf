# AWS EKS 클러스터 구성
resource "aws_eks_cluster" "main" {
  # 클러스터의 이름과 IAM 역할 ARN 설정
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  # 클러스터가 위치할 VPC 설정과 공개 엔드포인트 접근 관리
  vpc_config {
    subnet_ids         = var.subnet_ids
    endpoint_public_access = true
    public_access_cidrs = ["0.0.0.0/0"]
  }

  # IAM 정책 연결이 완료된 후 클러스터 생성을 보장
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# AWS EKS 노드 그룹 구성
resource "aws_eks_node_group" "main" {
  # 각 노드 그룹 설정 반복
  for_each = var.node_groups

  # 클러스터 ID, 노드 그룹 이름, IAM 역할 ARN 설정
  cluster_name    = aws_eks_cluster.main.id
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.subnet_ids

  # 노드 그룹의 디스크 크기와 인스턴스 유형 설정
  disk_size       = each.value.disk_size
  instance_types  = [each.value.instance_type]
  capacity_type = "SPOT"
  # 노드 그룹의 스케일링 설정 (최소, 원하는, 최대 크기)
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }

  # IAM 정책 연결이 완료된 후 노드 그룹 생성을 보장
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_policy
  ]
}

# EKS 클러스터 관리를 위한 IAM 역할 생성
resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster_role"

  # AWS 서비스가 이 역할을 가정할 수 있도록 정책 설정
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# EKS 노드 운영을 위한 IAM 역할 생성
resource "aws_iam_role" "eks_node" {
  name = "eks_node_role"

  # AWS 서비스가 이 역할을 가정할 수 있도록 정책 설정
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# 클러스터 관리를 위한 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# 노드 운영을 위한 IAM 정책 연결
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
