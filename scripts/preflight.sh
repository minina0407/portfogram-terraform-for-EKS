#!/bin/bash
# preflight.sh - Terraform apply 전 사전 점검 스크립트

set -e

ENVIRONMENT=${1:-dev}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "✈️  Running preflight checks for environment: $ENVIRONMENT"

cd "$PROJECT_ROOT/envs/$ENVIRONMENT"

# 1. Terraform plan 실행
echo "Running terraform plan..."
terraform plan -out=tfplan -var-file="${ENVIRONMENT}.tfvars"

# 2. Plan 결과 확인
if [ ! -f "tfplan" ]; then
    echo "❌ Terraform plan failed"
    exit 1
fi

echo "✅ Terraform plan completed successfully"
echo "📋 Plan file saved as tfplan"

# 3. 리소스 변경 사항 요약
echo ""
echo "📊 Resource changes summary:"
terraform show -json tfplan | jq -r '
  .resource_changes[] | 
  select(.change.actions[] != "no-op") |
  "\(.change.actions | join(",")) \(.address)"
' || echo "No changes detected"

# 4. 파괴적 변경 확인
echo ""
echo "⚠️  Checking for destructive changes..."
DESTRUCTIVE=$(terraform show -json tfplan | jq '[.resource_changes[] | select(.change.actions[] == "delete")] | length')

if [ "$DESTRUCTIVE" -gt 0 ]; then
    echo "⚠️  WARNING: $DESTRUCTIVE resource(s) will be destroyed!"
    echo "Destructive changes:"
    terraform show -json tfplan | jq -r '
      .resource_changes[] | 
      select(.change.actions[] == "delete") |
      "  - \(.address)"
    '
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Aborted by user"
        exit 1
    fi
else
    echo "✅ No destructive changes detected"
fi

echo "✅ Preflight checks completed"

