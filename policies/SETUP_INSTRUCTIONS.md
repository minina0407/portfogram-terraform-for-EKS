# GitHub Actions OIDC IAM 권한 설정 가이드

## 문제
GitHub Actions에서 Terraform을 실행할 때 다음 권한 오류가 발생합니다:
- `iam:CreateRole` 권한 없음
- `kms:TagResource` 권한 없음

## 해결 방법

AWS 콘솔에서 `github-actions-oidc` 역할에 필요한 권한을 추가해야 합니다.

### 1. IAM 콘솔 접속
1. AWS 콘솔 → IAM → Roles
2. `github-actions-oidc` 역할 선택

### 2. 권한 정책 추가 (AWS 콘솔)

1. IAM → Roles → `github-actions-oidc`
2. "Add permissions" → "Create inline policy"
3. JSON 탭 선택
4. `policies/github-actions-oidc-policy.json` 파일 내용을 복사해서 붙여넣기
5. 정책 이름: `TerraformFullAccess`
6. "Create policy" 클릭

### 3. 필요한 최소 권한 (보안 강화용 - 선택사항)

프로덕션 환경에서는 최소 권한 원칙을 적용하려면 다음 정책을 사용하세요:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags",
        "ec2:Describe*",
        "ec2:Create*",
        "ec2:Delete*",
        "ec2:Modify*",
        "ec2:Authorize*",
        "ec2:Revoke*",
        "ec2:Associate*",
        "ec2:Disassociate*",
        "ec2:Attach*",
        "ec2:Detach*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:ListRoles",
        "iam:UpdateRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:ListAttachedRolePolicies",
        "iam:CreatePolicy",
        "iam:DeletePolicy",
        "iam:GetPolicy",
        "iam:ListPolicies",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:PassRole"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. 확인

다시 GitHub Actions 워크플로우를 실행하여 정상 동작하는지 확인하세요.

## 참고사항

- 이 정책은 Terraform이 EKS 클러스터, 네트워크, 보안, 스토리지 리소스를 생성/수정/삭제하는데 필요한 모든 권한을 포함합니다
- 프로덕션 환경에서는 리소스별로 더 세밀한 권한 제어를 고려하세요
- 필요에 따라 특정 리소스 ARN으로 제한할 수 있습니다

