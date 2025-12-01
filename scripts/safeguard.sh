#!/bin/bash
# safeguard.sh - Terraform 실행 전 안전성 검사 스크립트

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔒 Running safeguard checks for environment: $ENVIRONMENT"

# 1. Terraform 버전 확인
echo "Checking Terraform version..."
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    exit 1
fi

TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
echo "✅ Terraform version: $TF_VERSION"

# 2. AWS 자격 증명 확인
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured"
    exit 1
fi

AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account: $AWS_ACCOUNT"

# 3. Terraform 초기화 확인
echo "Checking Terraform initialization..."
cd "$PROJECT_ROOT/envs/$ENVIRONMENT"
if [ ! -d ".terraform" ]; then
    echo "⚠️  Terraform not initialized. Running terraform init..."
    terraform init
fi

# 4. Terraform 포맷 확인
echo "Checking Terraform formatting..."
if ! terraform fmt -check -recursive "$PROJECT_ROOT/envs/$ENVIRONMENT"; then
    echo "❌ Terraform files are not properly formatted"
    echo "Run 'terraform fmt -recursive' to fix"
    exit 1
fi
echo "✅ Terraform files are properly formatted"

# 5. Terraform 검증
echo "Validating Terraform configuration..."
if ! terraform validate; then
    echo "❌ Terraform validation failed"
    exit 1
fi
echo "✅ Terraform configuration is valid"

# 6. 백엔드 상태 확인 (S3)
echo "Checking backend state..."
if terraform state list &> /dev/null; then
    echo "✅ Backend state is accessible"
else
    echo "⚠️  Backend state not accessible (may be first run)"
fi

echo "✅ All safeguard checks passed"

