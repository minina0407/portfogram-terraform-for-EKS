# EKS 클러스터를 관리하기 위한 IAM 역할 정의
resource "aws_iam_role" "eks_cluster" {
  name = "eks_cluster_role"

  # EKS 서비스가 이 역할을 수행할 수 있도록 허용하는 정책 설정
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

# EKS 노드 그룹을 관리하기 위한 IAM 역할 정의
resource "aws_iam_role" "eks_node" {
  name = "eks_node_role"

  # EC2 서비스가 이 역할을 수행할 수 있도록 허용하는 정책 설정
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

# EKS 클러스터 관리 역할에 필수 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS 클러스터 관리 역할에 VPC 리소스 컨트롤러 정책 연결
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS 노드 그룹 관리 역할에 필수 정책 연결
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# EKS 노드 그룹 관리 역할에 CNI(컨테이너 네트워크 인터페이스) 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
