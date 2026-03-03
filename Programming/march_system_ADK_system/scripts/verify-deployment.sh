#!/usr/bin/env bash
# Verify deployed March API and UI.
# Usage: ./verify-deployment.sh
set -euo pipefail

ORIGIN="http://march-ui-dev-533267377472.s3-website-us-east-1.amazonaws.com"
API="http://march-staging-alb-2122679412.us-east-1.elb.amazonaws.com"

echo "=== March Deployment Verification ==="
echo ""

echo "1. Health endpoint"
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" "$API/health")
echo "   GET /health: $HEALTH"
if [[ "$HEALTH" != "200" ]]; then
  echo "   FAIL: expected 200"
else
  echo "   OK"
fi

echo ""
echo "2. CORS headers (required for UI to show API Ready)"
CORS_HEADERS=$(curl -s -i "$API/health" -H "Origin: $ORIGIN" 2>/dev/null | grep -i "access-control-allow-origin" || true)
if [[ -z "$CORS_HEADERS" ]]; then
  echo "   FAIL: missing Access-Control-Allow-Origin"
  echo "   The UI will show 'API Offline' until the API returns this header."
  echo "   Fix: Ensure ECS task uses task definition with MARCH_CORS_ALLOW_ORIGINS including S3 origins."
else
  echo "   OK: $CORS_HEADERS"
fi

echo ""
echo "3. OPTIONS preflight /api/v1/chat/message"
OPTIONS_MSG=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "$API/api/v1/chat/message" \
  -H "Origin: $ORIGIN" -H "Access-Control-Request-Method: POST")
echo "   OPTIONS: $OPTIONS_MSG (expect 200)"
if [[ "$OPTIONS_MSG" != "200" ]]; then
  echo "   FAIL: Chat POST will be blocked by CORS"
else
  echo "   OK"
fi

echo ""
echo "4. OPTIONS preflight /api/v1/chat/stream"
OPTIONS_STREAM=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS "$API/api/v1/chat/stream" -H "Origin: $ORIGIN")
echo "   OPTIONS: $OPTIONS_STREAM (expect 200)"
if [[ "$OPTIONS_STREAM" != "200" ]]; then
  echo "   WARN: SSE stream may have CORS issues"
else
  echo "   OK"
fi

echo ""
echo "5. POST /api/v1/chat/message (sanity)"
POST_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$API/api/v1/chat/message" \
  -H "Origin: $ORIGIN" -H "Content-Type: application/json" \
  -d '{"message":"test","patient_id":"test-123","conversation_id":"conv-test"}')
echo "   POST: $POST_STATUS (expect 200 or 202)"

echo ""
echo "6. ECS deployment status"
aws ecs describe-services --cluster march-staging-cluster --services march-staging-service \
  --query 'services[0].deployments[*].{taskDef:taskDefinitionArn,running:runningCount,rollout:rolloutState}' \
  --output table 2>/dev/null || echo "   (aws cli not configured or cluster not found)"
echo ""
