#!/usr/bin/env bash
# Deploy all March services to AWS.
# Usage: ./deploy-all.sh [options] [target]
#
# Targets:
#   all       Deploy API + UI (default)
#   api       Deploy March API only (ECS)
#   ui        Deploy March UI only (S3)
#
# Options:
#   --tag TAG       Docker image tag (default: latest)
#   --ui-env ENV    UI env: dev, staging, prod, or all (default: all)
#   --skip-terraform  Skip Terraform (default: skip)
#   --terraform      Run Terraform apply before deploy (use with caution)
#
# Examples:
#   ./deploy-all.sh                    # API + UI (all envs)
#   ./deploy-all.sh api                # API only
#   ./deploy-all.sh ui --ui-env staging  # UI staging only
#   ./deploy-all.sh --tag v1.2.3       # Deploy with specific tag
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MARCH_AGENT="${REPO_ROOT}/MarchAgent"
TF_DIR="${MARCH_AGENT}/infra/terraform"
WEB_DIR="${MARCH_AGENT}/web"

TAG="latest"
TARGET="all"
UI_ENV="all"
RUN_TERRAFORM=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --ui-env)
      UI_ENV="$2"
      shift 2
      ;;
    --terraform)
      RUN_TERRAFORM=true
      shift
      ;;
    --skip-terraform)
      RUN_TERRAFORM=false
      shift
      ;;
    api|ui|all)
      TARGET="$1"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: $0 [--tag TAG] [--ui-env dev|staging|prod|all] [--terraform] [api|ui|all]"
      exit 1
      ;;
  esac
done

AWS_REGION="${AWS_REGION:-us-east-1}"
AWS_ACCOUNT="533267377472"
REGISTRY="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "=============================================="
echo "  March AWS Full Deployment"
echo "=============================================="
echo "  Target:     $TARGET"
echo "  Image tag:  $TAG"
echo "  UI env:     $UI_ENV"
echo "  Terraform:  $RUN_TERRAFORM"
echo "=============================================="
echo ""

# -----------------------------------------------------------------------------
# Terraform (optional)
# -----------------------------------------------------------------------------
if [[ "$RUN_TERRAFORM" == true ]]; then
  echo "==> [1/4] Terraform apply"
  cd "$TF_DIR"
  if [[ ! -f terraform.tfvars ]]; then
    echo "ERROR: Create terraform.tfvars from terraform.tfvars.example"
    exit 1
  fi
  terraform init -input=false
  terraform plan -out=tfplan -input=false
  terraform apply -input=false tfplan
  rm -f tfplan
  echo ""
else
  echo "==> [1/4] Skipping Terraform (use --terraform to run)"
  echo ""
fi

# -----------------------------------------------------------------------------
# API (ECS)
# -----------------------------------------------------------------------------
deploy_api() {
  echo "==> Deploy March API to ECS"
  cd "$TF_DIR"

  API_ECR="$(terraform output -raw ecr_api_url 2>/dev/null || true)"
  CLUSTER="$(terraform output -raw ecs_cluster_name 2>/dev/null || true)"
  SVC="$(terraform output -raw ecs_service_name 2>/dev/null || true)"

  if [[ -z "$API_ECR" || -z "$CLUSTER" || -z "$SVC" ]]; then
    echo "WARN: Terraform outputs missing. Using fallback (march-staging-cluster, march-staging-service)"
    CLUSTER="${CLUSTER:-march-staging-cluster}"
    SVC="${SVC:-march-staging-service}"
    API_ECR="${API_ECR:-${REGISTRY}/march-agent}"
  fi

  IMAGE_URI="${API_ECR}:${TAG}"
  MARCH_AGENT_ECR="${REGISTRY}/march-agent"

  echo "     ECR: $API_ECR"
  echo "     Cluster: $CLUSTER, Service: $SVC"
  echo ""

  echo "     ECR login..."
  aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${REGISTRY}"

  echo "     Building image (linux/amd64)..."
  docker build --platform linux/amd64 -t "$IMAGE_URI" -f "${MARCH_AGENT}/Dockerfile" "$MARCH_AGENT"

  echo "     Pushing to ECR..."
  docker push "$IMAGE_URI"

  if [[ "$API_ECR" != "$MARCH_AGENT_ECR" ]]; then
    echo "     Pushing to march-agent..."
    docker tag "$IMAGE_URI" "${MARCH_AGENT_ECR}:${TAG}"
    docker push "${MARCH_AGENT_ECR}:${TAG}"
  fi

  echo "     Registering task definition..."
  TASKDEF_JSON="${MARCH_AGENT}/deploy/taskdef-staging.json"
  IMAGE_URI_ECS="${MARCH_AGENT_ECR}:${TAG}"
  TMP_TASKDEF="/tmp/taskdef-staging-$$.json"
  jq --arg IMG "${IMAGE_URI_ECS}" '.containerDefinitions[0].image = $IMG' "$TASKDEF_JSON" > "$TMP_TASKDEF"
  TASK_DEF_ARN=$(aws ecs register-task-definition \
    --cli-input-json "file://${TMP_TASKDEF}" \
    --region "$AWS_REGION" \
    --query 'taskDefinition.taskDefinitionArn' \
    --output text)
  rm -f "$TMP_TASKDEF"
  echo "     Task def: $TASK_DEF_ARN"

  echo "     Updating ECS service..."
  aws ecs update-service \
    --cluster "$CLUSTER" \
    --service "$SVC" \
    --task-definition "$TASK_DEF_ARN" \
    --force-new-deployment \
    --region "$AWS_REGION" \
    --output json >/dev/null

  ALB_DNS="$(terraform output -raw alb_dns_name 2>/dev/null || true)"
  echo ""
  echo "     API deploy triggered. URL: http://${ALB_DNS:-<alb_dns>}"
  echo ""
}

# -----------------------------------------------------------------------------
# UI (S3)
# -----------------------------------------------------------------------------
deploy_ui() {
  echo "==> Deploy March UI to S3"
  cd "$WEB_DIR"

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
    [[ -z "$bucket" ]] && { echo "Unknown env: $env"; return 1; }

    echo "     Building for $env..."
    npx vite build --mode "$env"

    echo "     Ensuring bucket $bucket exists..."
    if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
      aws s3 mb "s3://$bucket" --region "$AWS_REGION"
      aws s3api put-public-access-block --bucket "$bucket" \
        --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
      aws s3api put-bucket-policy --bucket "$bucket" --policy "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadGetObject\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::${bucket}/*\"}]}"
    fi

    aws s3 website "s3://$bucket" --index-document index.html --error-document index.html
    echo "     Syncing versioned assets to s3://$bucket..."
    aws s3 sync dist/ "s3://$bucket" --delete \
      --exclude "index.html" \
      --cache-control "public,max-age=31536000,immutable"
    echo "     Uploading index.html with no-cache..."
    aws s3 cp dist/index.html "s3://$bucket/index.html" \
      --cache-control "no-cache,no-store,must-revalidate" \
      --content-type "text/html; charset=utf-8"
    echo "     $env: http://${bucket}.s3-website-${AWS_REGION}.amazonaws.com/"
  }

  npm ci --silent 2>/dev/null || npm install

  case "$UI_ENV" in
    dev)     deploy_env dev ;;
    staging) deploy_env staging ;;
    prod)    deploy_env prod ;;
    all)
      deploy_env dev
      deploy_env staging
      deploy_env prod
      ;;
    *)
      echo "ERROR: Invalid --ui-env: $UI_ENV (use dev|staging|prod|all)"
      exit 1
      ;;
  esac
  echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
case "$TARGET" in
  api)
    deploy_api
    ;;
  ui)
    deploy_ui
    ;;
  all)
    deploy_api
    deploy_ui
    ;;
  *)
    echo "ERROR: Invalid target: $TARGET"
    exit 1
    ;;
esac

echo "==> Deployment complete"
echo ""
echo "Next steps:"
echo "  - Wait 2-5 min for ECS tasks to stabilize"
echo "  - Verify: curl http://march-staging-alb-2122679412.us-east-1.elb.amazonaws.com/v1/patients"
echo "  - UI: http://march-ui-staging-533267377472.s3-website-us-east-1.amazonaws.com/"
echo ""
