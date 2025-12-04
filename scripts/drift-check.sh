#!/bin/bash
# drift-check.sh - Terraform 상태와 실제 인프라 간 드리프트 검사

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔍 Running drift check for environment: $ENVIRONMENT"

cd "$PROJECT_ROOT/envs/$ENVIRONMENT"

# 1. Terraform 초기화 확인
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# 2. 상태 새로고침
echo "Refreshing Terraform state..."
terraform refresh -var-file="${ENVIRONMENT}.tfvars"

# 3. Plan 실행 (드리프트 감지)
echo "Running terraform plan to detect drift..."
terraform plan -var-file="${ENVIRONMENT}.tfvars" -detailed-exitcode > /tmp/drift-plan.txt 2>&1
PLAN_EXIT_CODE=$?

case $PLAN_EXIT_CODE in
    0)
        echo "✅ No drift detected - infrastructure matches state"
        ;;
    1)
        echo "❌ Error occurred during drift check"
        cat /tmp/drift-plan.txt
        exit 1
        ;;
    2)
        echo "⚠️  Drift detected - infrastructure differs from state"
        echo ""
        echo "Drift details:"
        cat /tmp/drift-plan.txt
        echo ""
        echo "To fix drift, run: terraform apply"
        exit 2
        ;;
esac

# 4. 상태 파일 백업 확인
STATE_FILE="terraform.tfstate"
if [ -f "$STATE_FILE" ]; then
    BACKUP_FILE="${STATE_FILE}.backup"
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "⚠️  No backup state file found"
    else
        echo "✅ State backup file exists"
    fi
fi

echo "✅ Drift check completed"

