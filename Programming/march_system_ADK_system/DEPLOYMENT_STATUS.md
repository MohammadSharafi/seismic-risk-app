# March Deployment Status

## Verification Summary (fixed)

| Component | Status | Notes |
|-----------|--------|-------|
| **API /health** | ✅ 200 OK | Backend is running |
| **CORS for /health** | ✅ OK | `Access-Control-Allow-Origin` present → UI shows "API Ready" |
| **OPTIONS /api/v1/chat/message** | ✅ 200 | Chat POST works from browser |
| **OPTIONS /api/v1/chat/stream** | ⚠️ 405 | SSE uses GET (EventSource) so typically works without preflight |
| **POST /api/v1/chat/message** | ✅ 200 | Endpoint responds |

## Fix Applied

1. **Task definition 5** with `MARCH_CORS_ALLOW_ORIGINS` including S3 origins
2. **ECS service** updated to use **public subnets** with `assignPublicIp=ENABLED` (tasks in private subnets could not reach ECR to pull images)
3. **Full API deploy** (build + push to march-staging-api and march-agent)

## What Was Done

1. **Task definition 5** created (based on task def 1) with `MARCH_CORS_ALLOW_ORIGINS` including all S3 origins.
2. **Deploy script** updated to also push to `march-agent` (the image ECS actually uses).
3. **deploy/taskdef-staging.json** updated with CORS and CSRF origins for S3.
4. **Verification script** added at `scripts/verify-deployment.sh`.

## Required Fix

The ECS service must run a task definition that includes `MARCH_CORS_ALLOW_ORIGINS` with the S3 origins. Task definition 5 has this, but its tasks were still rolling out at last check.

### Option A: Wait for Task Def 5 Rollout

```bash
# Check deployment
aws ecs describe-services --cluster march-staging-cluster --services march-staging-service \
  --query 'services[0].deployments'

# When task def 5 shows runningCount: 1, run:
./scripts/verify-deployment.sh
```

### Option B: Redeploy API and Force New Tasks

```bash
cd MarchAgent
./scripts/deploy-api-only.sh   # Builds, pushes to march-staging-api AND march-agent
# Then ensure service uses a task def with MARCH_CORS_ALLOW_ORIGINS
aws ecs update-service --cluster march-staging-cluster --service march-staging-service \
  --task-definition march-staging-task:5 --force-new-deployment
```

### Option C: Update Task Definition via AWS Console

1. ECS → Task Definitions → march-staging-task
2. Create new revision
3. Add env var: `MARCH_CORS_ALLOW_ORIGINS` = `http://localhost:5173,http://127.0.0.1:5173,http://localhost:3000,http://127.0.0.1:3000,http://march-ui-533267377472.s3-website-us-east-1.amazonaws.com,http://march-ui-dev-533267377472.s3-website-us-east-1.amazonaws.com,http://march-ui-staging-533267377472.s3-website-us-east-1.amazonaws.com`
4. Update service to use the new revision

## Run Verification

```bash
./scripts/verify-deployment.sh
```

## URLs

- **Dev UI**: http://march-ui-dev-533267377472.s3-website-us-east-1.amazonaws.com/
- **Staging UI**: http://march-ui-staging-533267377472.s3-website-us-east-1.amazonaws.com/
- **Prod UI**: http://march-ui-533267377472.s3-website-us-east-1.amazonaws.com/
- **API**: http://march-staging-alb-2122679412.us-east-1.elb.amazonaws.com
