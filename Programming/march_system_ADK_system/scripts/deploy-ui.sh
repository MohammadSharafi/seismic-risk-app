#!/usr/bin/env bash
# Deploy March UI to S3 (dev, staging, prod).
# Usage: ./deploy-ui.sh [dev|staging|prod|all]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(cd "$SCRIPT_DIR/../web" && pwd)"
ENV="${1:-all}"
AWS_ACCOUNT="533267377472"
AWS_REGION="us-east-1"

get_bucket() {
  case "$1" in
    dev)     echo "march-ui-dev-533267377472" ;;
    staging) echo "march-ui-staging-533267377472" ;;
    prod)    echo "march-ui-533267377472" ;;
    *)       echo "" ;;
  esac
}

deploy_env() {
  local env=$1
  local bucket
  bucket=$(get_bucket "$env")
  [[ -z "$bucket" ]] && { echo "Unknown env: $env"; exit 1; }

  echo "==> Building for $env"
  cd "$WEB_DIR"
  npx vite build --mode "$env"

  echo "==> Creating bucket $bucket (if not exists)"
  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    aws s3 mb "s3://$bucket" --region "$AWS_REGION"
    aws s3api put-public-access-block --bucket "$bucket" \
      --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
    aws s3api put-bucket-policy --bucket "$bucket" --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::${bucket}/*\"}]}"
  fi

  echo "==> Enabling static website hosting"
  aws s3 website "s3://$bucket" \
    --index-document index.html \
    --error-document index.html

  echo "==> Syncing dist/ to s3://$bucket"
  aws s3 sync dist/ "s3://$bucket" --delete

  echo "==> $env deployed: http://${bucket}.s3-website-${AWS_REGION}.amazonaws.com/"
}

cd "$WEB_DIR"
npm ci --silent 2>/dev/null || npm install

case "$ENV" in
  dev)     deploy_env dev ;;
  staging) deploy_env staging ;;
  prod)    deploy_env prod ;;
  all)
    deploy_env dev
    deploy_env staging
    deploy_env prod
    ;;
  *)
    echo "Usage: $0 [dev|staging|prod|all]"
    exit 1
    ;;
esac

echo "Done."
